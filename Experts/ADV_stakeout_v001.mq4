//+------------------------------------------------------------------+
//|                                            ADV_stakeout_v001.mq4 |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""


extern string some_text;
extern datetime sendDateTime=0;
extern int IntervalMinute=30;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//----
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
//----

if(TimeCurrent()-sendDateTime<IntervalMinute*60) return(0);

      sendDateTime=TimeCurrent();
      string orderStr = ""; 
      for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      orderStr = orderStr+"\n"+
         " OrderTicket="+OrderTicket()+" OrderOpenTime="+TimeHour(OrderOpenTime())+":"+TimeMinute(OrderOpenTime())+" OrderSymbol="+OrderSymbol()
         +" OrderType="+OrderType()+" OrderLots()="+OrderLots()+" OrderOpenPrice="+OrderOpenPrice()+" OrderStopLoss="+OrderStopLoss()+
         " OrderTakeProfit="+OrderTakeProfit()+" OrderClosePrice="+OrderClosePrice()+" OrderProfit="+OrderProfit()+
         " MAGICMA="+OrderMagicNumber();
       
     }
   some_text="AccountBalance="+AccountBalance()+"  AccountEquity="+AccountEquity()+
   " AccountProfit="+AccountProfit();
   some_text=some_text+"\n"+orderStr;
   
   SendMail("MT stakeout",some_text);
   Print("sendDateTime=",sendDateTime,"  some_text=",some_text);
//----
   return(0);
  }
//+------------------------------------------------------------------+