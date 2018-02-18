//+------------------------------------------------------------------+
//|                                     ADV_earthquake_USDJPY_H4_v028.mq4 |
//|                                                         zeng jin |
//|                           JPY              |
//+------------------------------------------------------------------+
#property copyright "zeng jin"
extern int     Magic = 10004;
#include <advlib.mqh>
 
extern int     Step=1500;
extern double  FirstLot=0.1;
extern double  IncLot=0.1;
extern double  MinProfit=145;
extern double StopProfit = 1000;
extern double stoploss = 10000;
extern double takeprofit = 1500;

extern double MovingPeriod       = 25;   
extern double MovingShift        = 0;
extern double deviation    =  1.75;
extern double IFDistance         = 1000;  //²î¾à
double gLotSell=0;
double gLotBuy=0;
double LSP,LBP;
 
int init()
{
  Comment("ADV_earthquake_USDJPY_H4_v28");
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
  double upIEnv = iEnvelopes(NULL,0, MovingPeriod, MODE_SMA,MovingShift,PRICE_WEIGHTED, deviation,MODE_UPPER,0);
  double loIEnv = iEnvelopes(NULL,0, MovingPeriod, MODE_SMA,MovingShift,PRICE_WEIGHTED, deviation,MODE_LOWER,0);
   // double ma=iMA(NULL,0,MovingPeriod,MovingShift,MODE_SMA,PRICE_WEIGHTED,MAShift);
    if(Ask<loIEnv)  {
      OrderSend(Symbol(),OP_BUY,FirstLot,Ask,30,0,0,"",Magic,0,Green);
     }
     if(Ask>upIEnv)  {
      OrderSend(Symbol(),OP_SELL,FirstLot,Bid,30,0,0,"",Magic,0,Red);
     }
  }
   if(MyOrdersTotal(Magic)>1){
   return(0);
   }
  
  if(MyOrdersTotal(Magic)==1){
  IncLot=0;
  }else if(MyOrdersTotal(Magic)==2){
  IncLot=0;
  }else {
  IncLot=0;
  }
 
  LSP=GetLastSellPrice(Magic);
  LBP=GetLastBuyPrice(Magic);
  
  
  
  if((LSP-Bid)<=Step*Point)
  {
    AdvOrderSend(Symbol(),OP_SELLLIMIT,gLotSell+IncLot,LSP+Step*Point,30,0,0,"",Magic,0,Red);
  }
 
  if((Ask-LBP)<=Step*Point)
  {
    AdvOrderSend(Symbol(),OP_BUYLIMIT,gLotBuy+IncLot,LBP-Step*Point,30,0,0,"",Magic,0,Red);
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