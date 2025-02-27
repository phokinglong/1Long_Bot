import os
import logging
import io
import base64
from typing import List
from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel
from sqlalchemy.orm import Session
from dotenv import load_dotenv
import openai
import matplotlib.pyplot as plt

from fastapi.responses import JSONResponse
from config.database import get_db
from app.models.investment import InvestmentPortfolio, Asset, AssetType

load_dotenv()
logging.basicConfig(level=logging.INFO)
openai.api_key = os.getenv("OPENAI_API_KEY")

router = APIRouter()

# Pydantic models
class AssetInput(BaseModel):
    asset_type: str  # "stock", "real_estate", "gold", "bank_deposit"
    value: float

class InvestmentRequest(BaseModel):
    user_id: int  # ✅ Added user_id to ensure it is provided
    risk_tolerance: str
    assets: List[AssetInput]

class InvestmentResponse(BaseModel):
    risk_tolerance: str
    total_value: float
    projected_value: float
    graph: str
    ai_rebalance_advice: str

def calculate_future_value(value: float, asset_type: AssetType, years: int = 5) -> float:
    """Tính giá trị tương lai sau 5 năm với lãi suất cố định."""
    rates = {
        AssetType.stock: 0.20,
        AssetType.real_estate: 0.12,
        AssetType.gold: 0.03,
        AssetType.bank_deposit: 0.05
    }
    r = rates.get(asset_type, 0)
    return value * ((1 + r) ** years)

def generate_growth_graph(assets: List[Asset]) -> str:
    """Vẽ biểu đồ tăng trưởng tài sản (5 năm) và trả về chuỗi base64 PNG."""
    years = list(range(0, 6))
    plt.figure(figsize=(8, 6))
    for asset in assets:
        rate = {
            AssetType.stock: 0.20,
            AssetType.real_estate: 0.12,
            AssetType.gold: 0.03,
            AssetType.bank_deposit: 0.05
        }[asset.asset_type]
        values = [asset.value * ((1 + rate) ** y) for y in years]
        plt.plot(years, values, label=asset.asset_type.value.capitalize())
    plt.xlabel("Năm")
    plt.ylabel("Giá Trị (VNĐ)")
    plt.title("Biểu Đồ Tăng Trưởng Tài Sản Sau 5 Năm")
    plt.legend()
    plt.grid(True)
    buf = io.BytesIO()
    plt.savefig(buf, format="png")
    plt.close()
    buf.seek(0)
    return base64.b64encode(buf.read()).decode("utf-8")

@router.post("/investment", response_model=InvestmentResponse)
async def create_investment_plan(request: InvestmentRequest, db: Session = Depends(get_db)) -> JSONResponse:
    """
    Nhận danh sách tài sản và mức độ rủi ro, tính toán giá trị hiện tại,
    giá trị dự kiến sau 5 năm, tạo biểu đồ tăng trưởng,
    và gọi OpenAI để đề xuất tái cân bằng danh mục bằng tiếng Việt.
    """
    if not request.assets or not request.risk_tolerance.strip():
        raise HTTPException(status_code=400, detail="Dữ liệu đầu vào không hợp lệ.")

    # ✅ Validate that user_id is not None
    if not request.user_id:
        raise HTTPException(status_code=400, detail="User ID is required.")

    # ✅ Ensure it's an integer
    try:
        user_id = int(request.user_id)
    except ValueError:
        raise HTTPException(status_code=400, detail="Invalid user ID format.")

    # ✅ Create InvestmentPortfolio with user_id
    portfolio = InvestmentPortfolio(
        user_id=user_id,  # ✅ Ensure user_id is included
        risk_tolerance=request.risk_tolerance
    )
    db.add(portfolio)
    db.commit()
    db.refresh(portfolio)

    total_value = 0.0
    asset_records = []
    for asset_input in request.assets:
        try:
            asset_type = AssetType(asset_input.asset_type)
        except ValueError:
            raise HTTPException(status_code=400, detail=f"Loại tài sản không hợp lệ: {asset_input.asset_type}")
        total_value += asset_input.value
        new_asset = Asset(
            portfolio_id=portfolio.id,
            asset_type=asset_type,
            value=asset_input.value
        )
        db.add(new_asset)
        asset_records.append(new_asset)

    db.commit()

    # Tính giá trị dự kiến sau 5 năm
    projected_value = sum(calculate_future_value(a.value, a.asset_type, years=5) for a in asset_records)

    # Tạo biểu đồ
    graph_base64 = generate_growth_graph(asset_records)

    # Prompt tiếng Việt
    asset_details = "\n".join([
        f"{a.asset_type.value.capitalize()}: {a.value} VNĐ" for a in asset_records
    ])
    prompt = (
        f"Tôi có danh mục đầu tư gồm các tài sản:\n{asset_details}\n"
        f"Tổng giá trị danh mục: {total_value} VNĐ. "
        f"Mức độ rủi ro của tôi là {request.risk_tolerance}.\n"
        "Hãy gợi ý cách tái cân bằng danh mục đầu tư hoàn toàn bằng tiếng Việt."
    )

    # Gọi OpenAI
    try:
        ai_response = openai.chat.completions.create(
            model="gpt-4-turbo",  # or "gpt-4"
            messages=[
                {
                    "role": "system",
                    "content": (
                        "Bạn là một cố vấn tài chính chuyên tái cân bằng danh mục đầu tư. "
                        "Luôn trả lời 100% bằng tiếng Việt, tuyệt đối không dùng tiếng Anh."
                    )
                },
                {"role": "user", "content": prompt},
            ],
            max_tokens=2000,
            temperature=0.7
        )
        # Encode+decode to ensure valid utf-8
        raw_advice = ai_response.choices[0].message.content.strip()
        ai_advice = raw_advice.encode("utf-8", "replace").decode("utf-8", "replace")

    except Exception as e:
        logging.exception("Lỗi gọi OpenAI")
        ai_advice = "Không thể lấy gợi ý tái cân bằng từ AI."

    # Trả về JSONResponse (UTF-8)
    response_data = {
        "risk_tolerance": portfolio.risk_tolerance,
        "total_value": total_value,
        "projected_value": projected_value,
        "graph": graph_base64,
        "ai_rebalance_advice": ai_advice
    }

    return JSONResponse(
        content=response_data,
        media_type="application/json; charset=utf-8"
    )
