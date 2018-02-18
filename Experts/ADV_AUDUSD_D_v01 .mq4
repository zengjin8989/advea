//+------------------------------------------------------------------+
//|                                     ADV_AUDUSD_D_v01.mq4 |
//|                                                         zeng jin |
//|                                         |
//+------------------------------------------------------------------+
#property copyright "zeng jin"

#include <advlib.mqh>
 
extern int     Step=4000;
extern double  FirstLot=0.1;
extern double  IncLot=0;
extern double  MinProfit=4000;
extern double takeprofit = 6000;
extern int     Magic = 2008;

extern double MovingPeriod       = 20;   
extern double MovingShift        = 1;
extern double deviation    =  2;

double gLotSell=0;
double gLotBuy=0;
double LSP,LBP;
 
int init()
{
  Comment("ADV_AUDUSD_D_v01");
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

 if(Volume[0]>20) return;
  double i;
  double sl,p;
 
 //if(MyOpOrdersTotal(Magic)>1){
 /*
  if (MyOpOrdersTotal(Magic)>1&&GetLastBuyProfit(Magic)>=MinProfit)
  {
  //Print("GetLastBuyProfit(Magic)="+GetLastBuyProfit(Magic));
    DeletePendingOrders(Magic);
    CloseLastOrder(Magic);
    //GlobalVariableSet("OldBalance",0);
 // }
  }else if (GetLastBuyProfit(Magic)>=takeprofit)
   {
     DeletePendingOrders(Magic);
     CloseOrders(Magic);
     //GlobalVariableSet("OldBalance",0);
   }
  */
  
  /*
   if (MyOrdersProfit(Magic)<=-StopProfit)
  {
    DeletePendingOrders(Magic);
    CloseOrders(Magic);
    GlobalVariableSet("OldBalance",0);
  }
  
  

  */
 
  //GlobalVariableSet("OldBalance",AccountBalance());
 
  
  
  /*
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
 */
 // LSP=GetLastSellPrice(Magic);
  LBP=GetLastBuyPrice(Magic);
  
 // Print("LBP==",LBP,"  Ask-LBP=",Ask-LBP," Step*Point= "+Step*Point,"  GetLastBuyProfit=",GetLastBuyProfit(Magic));
  
 // if((LSP-Bid)<=Step*Point)
 // {
   // OrderSend(Symbol(),OP_SELLLIMIT,gLotSell+IncLot,LSP+Step*Point,30,0,0,"",Magic,0,Red);
 // }
 if(MyOrdersTotal(Magic)>1&&LBP-Ask>=Step*Point)
   {
      AdvOrderSend(Symbol(),OP_BUY,gLotBuy+IncLot,Ask,30,0,Ask+MinProfit*Point,"",Magic,0,Navy);
      return;
   } else if(MyOrdersTotal(Magic)==1){
       double ma=iMA(NULL,0,360,MovingShift,MODE_SMA,PRICE_WEIGHTED,0);
       
       if(Ask+Step*Point<ma)  
     {
      OrderSend(Symbol(),OP_BUY,gLotBuy+IncLot,Ask,30,0,Ask+MinProfit*Point,"",Magic,0,Red);
      return;
     }
       
  }else  if (MyOrdersTotal(Magic)==0)
  {
  double upIEnv = iEnvelopes(NULL,0, MovingPeriod, MODE_LWMA,0,PRICE_WEIGHTED, deviation,MODE_UPPER,0);
  double loIEnv = iEnvelopes(NULL,0, MovingPeriod, MODE_LWMA,0,PRICE_WEIGHTED, deviation,MODE_LOWER,0);
   // double ma=iMA(NULL,0,MovingPeriod,MovingShift,MODE_SMA,PRICE_WEIGHTED,MAShift);
    if(Ask<loIEnv)  {
      OrderSend(Symbol(),OP_BUY,FirstLot,Ask,30,0,Ask+takeprofit*Point,"",Magic,0,Green);
     }
     if(Ask>upIEnv)  {
     // OrderSend(Symbol(),OP_SELL,FirstLot,Bid,30,0,0,"",Magic,0,Red);
    }
  }
  
  
  return(0);
}

 
double GetLastBuyPrice(int Magic)
{
  int total=OrdersTotal()-1;
 double OrderOpenPriceV= 0;
  for (int cnt = total ; cnt >=0 ; cnt--)
  {
    OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
    if (OrderMagicNumber() == Magic && OrderSymbol()==Symbol() && (OrderType()==OP_BUYLIMIT || OrderType()==OP_BUY))
    {
      gLotBuy=OrderLots();
    OrderOpenPriceV = OrderOpenPrice();
      return(OrderOpenPrice());
      break;
    }
  }
  return(OrderOpenPriceV);
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


double GetLastBuyProfit(int Magic)
{
int total=OrdersTotal()-1;
  double orderProfit = 0;
  for (int cnt = total ; cnt >=0 ; cnt--)
  {
    OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
    if (OrderMagicNumber() == Magic && OrderSymbol()==Symbol() && (OrderType()!=OP_BUYLIMIT && OrderType()!=OP_SELLLIMIT)
    &&(OrderType()==OP_BUY||OrderType()==OP_SELL))
    {
      orderProfit=OrderProfit();
      return(orderProfit);
      break;
      
    }
  }
  return(orderProfit);
}


int CloseLastOrder(int Magic)
{
  int total  = OrdersTotal();
  
  for (int cnt = total-1 ; cnt >= 1 ; cnt--)
  {
    OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
    if (OrderMagicNumber() == Magic && OrderSymbol()==Symbol())
    {
      if (OrderType()==OP_BUY)
      {
        OrderClose(OrderTicket(),OrderLots(),Bid,30);
        return(0);
      }
      
      if (OrderType()==OP_SELL)
      {
        OrderClose(OrderTicket(),OrderLots(),Ask,30);
          return(0);
      }
    }
  }
  return(0);
}


int MyOpOrdersTotal(int Magic)
{
  int c=0;
  int total  = OrdersTotal();
 
  for (int cnt = 0 ; cnt < total ; cnt++)
  {
    OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
     if (OrderMagicNumber() == Magic && OrderSymbol()==Symbol() && (OrderType()!=OP_BUYLIMIT && OrderType()!=OP_SELLLIMIT)
    &&(OrderType()==OP_BUY||OrderType()==OP_SELL))
    {
      c++;
    }
  }
  return(c);
}