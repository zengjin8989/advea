//+------------------------------------------------------------------+
//|                                                       advlib.mqh |
//|                                       |
//|                                 |
//+------------------------------------------------------------------+


#include <stderror.mqh>
#include <stdlib.mqh>
#define Color_OP_BUY_Order                    Green
#define Color_OP_SELL_Order                    Red
#define Color_CLOSE_Order                      White
 

/*
判断此EA是否有下定单
*/
int CalculateCurrentOrders(string symbol,int magic)
  {
   int buys=0,sells=0;
//----
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==magic)
        {
        //Print("CalculateCurrentOrdersOrderType="+OrderType());
         if(OrderType()==OP_BUY)  buys++;
         if(OrderType()==OP_BUYSTOP)  buys++;
         if(OrderType()==OP_SELL) sells++;
         if(OrderType()==OP_SELLSTOP) sells++;
        }
     }
//---- return orders volume
   if(buys>0) return(buys);
   else       return(-sells);
  }

/*
判断此EA是否有下突破挂单
*/
int CalculateCurrentSTOPOrders(string symbol,int magic)
  {
   int buys=0,sells=0;
//----
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==magic)
        {
        //Print("CalculateCurrentOrdersOrderType="+OrderType());
         if(OrderType()==OP_BUYSTOP)  buys++;
         if(OrderType()==OP_SELLSTOP) sells++;
        }
     }
//---- return orders volume
   if(buys>0) return(buys);
   else       return(-sells);
  }


//这个功能主要应用于开仓位置和挂单交易.   
int AdvOrderSend(string symbol, int cmd, double volume, double price, int slippage, double stoploss, double takeprofit, string comment, int magic, int expiration, int arrow_color) 
{
    int res = OrderSend(symbol,cmd,volume,price,slippage,0,0,comment,magic,expiration,arrow_color);
    if(res>=0){
      OrderModify(res,price,stoploss,takeprofit,expiration,arrow_color);
    }
    else{
      int err=GetLastError();
      Print(" AdvOrderSend ERROR (",err,"): ",ErrorDescription(err));
    }
    return(res);
}

/**
获取前N根K的最高值.
*/
double getiHighVByNK(string symbol, int timeframe , int nk)
{ 
    double h1 = iHigh(symbol,timeframe,1);

     for(int i=1;i<=nk;i++){
         if(iHigh(symbol,timeframe,i)>h1){
           h1=iHigh(symbol,timeframe,i);
         }
     }
     return(h1);
}

/**
获取前N根K的最低值.
*/
double getiLowVByNK(string symbol, int timeframe , int nk)
{ 
    double l1 = iLow(symbol,timeframe,1);

     for(int i=1 ;i<=nk;i++){
         if(iLow(symbol,timeframe,i)<l1){
           l1=iLow(symbol,timeframe,i);
         }
     }
     return(l1);
}



int DeletePendingOrders(int Magic)
{
  int total  = OrdersTotal();
  
  for (int cnt = total-1 ; cnt >= 0 ; cnt--)
  {
    OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
    if (OrderMagicNumber() == Magic && OrderSymbol()==Symbol() && (OrderType()!=OP_BUY && OrderType()!=OP_SELL))
    {
      OrderDelete(OrderTicket());
    }
  }
  return(0);
}
 
int CloseOrders(int Magic)
{
  int total  = OrdersTotal();
  
  for (int cnt = total-1 ; cnt >= 0 ; cnt--)
  {
    OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
    if (OrderMagicNumber() == Magic && OrderSymbol()==Symbol())
    {
      if (OrderType()==OP_BUY)
      {
        OrderClose(OrderTicket(),OrderLots(),Bid,30);
      }
      
      if (OrderType()==OP_SELL)
      {
        OrderClose(OrderTicket(),OrderLots(),Ask,30);
      }
    }
  }
  return(0);
}
 
int MyOrdersTotal(int Magic)
{
  int c=0;
  int total  = OrdersTotal();
 
  for (int cnt = 0 ; cnt < total ; cnt++)
  {
    OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
    if (OrderMagicNumber() == Magic && OrderSymbol()==Symbol())
    {
      c++;
    }
  }
  return(c);
}

double MyOrdersProfit(int Magic)
{
int total=OrdersTotal()-1;
  double orderProfit = 0;
  for (int cnt = total ; cnt >=0 ; cnt--)
  {
    OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
    if (OrderMagicNumber() == Magic && OrderSymbol()==Symbol() && (OrderType()!=OP_BUYLIMIT && OrderType()!=OP_SELLLIMIT)
    &&(OrderType()==OP_BUY||OrderType()==OP_SELL))
    {
      orderProfit+=OrderProfit();
      
    }
  }
  return(orderProfit);
}


int GetLastOrderType(int Magic)
{
  int total  = OrdersTotal();
  
  for (int cnt = total-1 ; cnt >= 1 ; cnt--)
  {
    OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
    if (OrderMagicNumber() == Magic && OrderSymbol()==Symbol())
    {
      if (OrderType()==OP_BUY)
      {
        return(OP_BUY);
      }
      
      if (OrderType()==OP_SELL)
      {
         return(OP_SELL);
      }
    }
  }
  return(-1);
}


/**
获取标准离差最大值
*/
double getStdDevMaxValue(int stdDevShift,int stdDev_ma_period)
{
   double maxStdDevV=0;
   for(int i =0;i<stdDevShift;i++){
      if(maxStdDevV<iStdDev(NULL,0,stdDev_ma_period,0,MODE_SMA,PRICE_WEIGHTED,i)){
        maxStdDevV=iStdDev(NULL,0,stdDev_ma_period,0,MODE_SMA,PRICE_WEIGHTED,i);
      }
   }
   return(maxStdDevV);
}

/**
*来自交易历史的金额
*/
double getHisProfitV(int Magic){
    // 来自交易历史的恢复信息
    double profit=0;
  int i,hstTotal=OrdersHistoryTotal();
  for(i=0;i<hstTotal;i++)
    {
     //---- 检查选择结果
     if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==false)
       {
        Print("带有 (",GetLastError(),")错误的历史失败通道");
        break;
       }
       if(OrderSymbol()!=Symbol()||OrderMagicNumber()!=Magic ) continue;
        profit+=OrderProfit();
        if(profit>0){
         profit=0;
        }
  }
   Print("init()  ",profit);
   return(profit);

}

/**
*来自交易历史的最后金额
*/
double getHisProfitLV(int Magic){
    // 来自交易历史的恢复信息
    double profit=0;
  int i,hstTotal=OrdersHistoryTotal();
  for(i=0;i<hstTotal;i++)
    {
     //---- 检查选择结果
     if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==false)
       {
        Print("带有 (",GetLastError(),")错误的历史失败通道");
        break;
       }
       if(OrderSymbol()==Symbol()&&OrderMagicNumber()==Magic ){
        profit=OrderProfit();
       }
  }
   return(profit);

}

double getHisProfitF(int Magic){
   int handle = FileOpen(Magic+".txt",FILE_CSV|FILE_READ,"\t");
   double profit=0;
   if(handle>0)
    {
     profit=FileReadNumber(handle);
     FileClose(handle);
    }
    return(profit);

}

double setHisProfitF(int Magic,double profit){
   datetime orderOpen=OrderOpenTime();

     int handle = FileOpen(Magic+".txt",FILE_CSV|FILE_WRITE,"\t");
   
   if(handle>0)
    {
     FileWrite(handle,profit, TimeToStr(orderOpen));
     FileClose(handle);
    }
   return(getHisProfitF(Magic));
}