from fastapi import APIRouter, HTTPException
from app.schemas.trade_finance_schema import TradeFinanceInput, TradeFinanceOutput
from app.services.trade_finance_service import get_trade_finance_advice

trade_finance_router = APIRouter(prefix="/trade-finance", tags=["trade-finance"])

@trade_finance_router.post("/advice", response_model=TradeFinanceOutput)
def trade_finance_advice(input_data: TradeFinanceInput):
    """
    Endpoint to unify user inputs and chosen prompt (1..10) 
    into a single AI query.
    """
    try:
        result = get_trade_finance_advice(input_data)
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
