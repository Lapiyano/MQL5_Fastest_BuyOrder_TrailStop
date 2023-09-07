// include the file Trade.mqh
#include<Trade\Trade.mqh>

// Create an instance of trade
CTrade trade;

// Input parameters
input int  NumOfOrders=1;   // Number of orders to place
input double LotSize=0.04;   // Lot size for each order
input double OrderPosition=7;   // Order position
input double Layer=1.0;   // Layer for order placement
input double TrailStop=15.0;   // Trailing stop value

double StopLoss = 0;

void OnTick()
{
   // Check if there are no open positions
   if(PositionsTotal()<1)
   {
      PlaceOrders();   
   } 
   
   // Get the current ask price
   double Ask=NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);                 
   CheckBuyTrailingStop(Ask);
} /// END MAIN

void PlaceOrders()
{
   // Get the current ask and bid prices
   double Ask=NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
   double Bid=NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits);
    
   // Place buy stop orders
   while(OrdersTotal()==0)
   {
      trade.BuyStop(LotSize,(Ask+((Layer*(10)+OrderPosition*(10))*_Point)),_Symbol,(Ask-(1000-OrderPosition*(10))*_Point),(Ask+(1000+OrderPosition*(10))*_Point),ORDER_TIME_GTC,0,NULL);
   }
          
   // Place buy market orders
   while(PositionsTotal()<1)
   {
      double Ask=NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);                                                              
      trade.Buy(LotSize,NULL,Ask,Ask-1000* _Point,Ask+1000* _Point,NULL);
   }   
}

void CheckBuyTrailingStop(double Ask)
{
   // Set the desired stop loss to TrailStop pips
   double SL=NormalizeDouble(Ask-(TrailStop*(10))*_Point,_Digits); 
  
   // Check all open positions for the current symbol
   for(int i=PositionsTotal()-1; i>=0; i--) // Count all currency pair positions
   {
      string symbol=PositionGetSymbol(i); // Get position symbol
   
      if (_Symbol==symbol) // If chart symbol matches position symbol	
      {
         if(PositionGetInteger(POSITION_TYPE)==ORDER_TYPE_BUY)
         {
            // Get position ticket number  
            ulong PositionTicket=PositionGetInteger(POSITION_TICKET);
    
            // Get the current stop loss 
            double CurrentStopLoss=PositionGetDouble(POSITION_SL);
    
            // Get buy position 
            double PositionBuyPrice = PositionGetDouble(POSITION_PRICE_OPEN);
   
            double Bid=NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits);
    
            // Check if the trailing stop condition is met
            if((Bid-CurrentStopLoss)>(TrailStop*10)*_Point)
            {
               // Modify the stop loss
               trade.PositionModify(PositionTicket,PositionBuyPrice+(Bid-PositionBuyPrice)-(TrailStop*10* _Point),PositionBuyPrice+(1000* _Point));
            }
         }
      }
   }
}
