//+------------------------------------------------------------------+
//|                                     ADV_jin_earthquake_USDJPY_H4_v19.mq4 |
//|                                                         zeng jin |
//|                           JPY              |
//+------------------------------------------------------------------+
#property copyright "zeng jin"

#include <advlib.mqh>
 
extern int     Step=1500;
extern double  FirstLot=0.1;
extern double  IncLot=0.1;
extern double  MinProfit=145;
extern double StopProfit = 1000;
extern double stoploss = 10000;
extern double takeprofit = 1500;
extern int     Magic = 2008;
extern int MAShift=8;
extern double MovingPeriod       = 30;   
extern double MovingShift        = 1;
extern double deviation    =  1.5;
extern double IFDistance         = 1000;  //²î¾à
double gLotSell=0;
double gLotBuy=0;
double LSP,LBP;
 
int init()
{
  Comment("ADV_jin_earthquake_USDJPY_H4_v19");
  GlobalVariableSet("OldBalance",AccountBalance());
  return(0);
}
int deinit()
{
  Comment("");
  return(0);
}
int start()
{
  double i;
  double sl,p;
 
  if (MyOrdersProfit(Magic)>=MinProfit)
  {
    DeletePendingOrders(Magic);
    CloseOrders(Magic);
    GlobalVariableSet("OldBalance",0);
  }
  
   if (MyOrdersProfit(Magic)<=-StopProfit)
  {
    DeletePendingOrders(Magic);
    CloseOrders(Magic);
    GlobalVariableSet("OldBalance",0);
  }
  
  

  
 
  GlobalVariableSet("OldBalance",AccountBalance());
 
  if (MyOrdersTotal(Magic)==0)
  {
  double upIEnv = iEnvelopes(NULL,0, MovingPeriod, MODE_LWMA,0,PRICE_WEIGHTED, deviation,MODE_UPPER,0);
  double loIEnv = iEnvelopes(NULL,0, MovingPeriod, MODE_LWMA,0,PRICE_WEIGHTED, deviation,MODE_LOWER,0);
   // double ma=iMA(NULL,0,MovingPeriod,MovingShift,MODE_SMA,PRICE_WEIGHTED,MAShift);
    if(Ask<loIEnv)  {
      OrderSend(Symbol(),OP_BUY,FirstLot,Ask,30,0,0,"",Magic,0,Green);
     }
     if(Ask>upIEnv)  {
      OrderSend(Symbol(),OP_SELL,FirstLot,Bid,30,0,0,"",Magic,0,Red);
     }
  }
   if(MyOrdersTotal(Magic)>2){
   return(0);
   }
  
  if(MyOrdersTotal(Magic)==1){
  IncLot=0;
  }else if(MyOrdersTotal(Magic)==2){
  IncLot=0.1;
  }else {
  IncLot=0;
  }
 
  LSP=GetLastSellPrice(Magic);
  LBP=GetLastBuyPrice(Magic);
  
  
  
  if((LSP-Bid)<=Step*Point)
  {
    OrderSend(Symbol(),OP_SELLLIMIT,gLotSell+IncLot,LSP+Step*Point,30,0,0,"",Magic,0,Red);
  }
 
  if((Ask-LBP)<=Step*Point)
  {
    OrderSend(Symbol(),OP_BUYLIMIT,gLotBuy+IncLot,LBP-Step*Point,30,0,0,"",Magic,0,Red);
  }
  
  return(0);
}

 
double GetLastBuyPrice(int Magic)
{
  int total=OrdersTotal()-1;
 
  for (int cnt = total ; cnt >=0 ; cnt--)
  {
    OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
    if (OrderMagicNumber() == Magic && OrderSymbol()==Symbol() && (OrderType()==OP_BUYLIMIT || OrderType()==OP_BUY))
    {
      gLotBuy=OrderLots();
      return(OrderOpenPrice());
      break;
    }
  }
  return(0);
}
 
double GetLastSellPrice(int Magic)
{
  int total=OrdersTotal()-1;
 
  for (int cnt = total ; cnt >=0 ; cnt--)
  {
    OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
    if (OrderMagicNumber() == Magic && OrderSymbol()==Symbol() && (OrderType()==OP_SELLLIMIT ||OrderType()==OP_SELL))
    {
      gLotSell=OrderLots();
     
      return(OrderOpenPrice());
      break;
    }
  }
  return(100000);
}