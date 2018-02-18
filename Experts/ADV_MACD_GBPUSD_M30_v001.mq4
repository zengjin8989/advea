//+------------------------------------------------------------------+
//|                                          ADV_MACD_GBPUSD_M30_v001.mq4 |
//|                                                         zeng jin |
//+------------------------------------------------------------------+
#property copyright "zeng jin"
#define MAGICMA  620090624
extern double Lots               = 0.1;
extern int col = 130;
extern double ifv=0.0026;
extern double MaximumRisk        = 0.02;
extern double DecreaseFactor     = 3;
extern double MovingPeriod       = 13;
extern double MovingPeriod2       = 21;
extern double MovingShift        = 0;
extern int fast_ema_period=11;
extern int slow_ema_period=21;
extern int signal_period=23;
extern int signal_period_m=23;

extern double profit             =0;
extern int    per = 14;
extern int    MaxSafety =10000;    //保险指数
extern double TrailingStop = 2600;
extern double StopLoss = 1200;
extern int    ShiftValue=0;
extern int    IFShiftValue=-1800;
   int type=OP_BUY;
   double openv,closev;
   int isClose=0;
   int isTClose=0;
   int CheckForOpen=0;
extern int multiple=1;   
//+------------------------------------------------------------------+
//| Calculate open positions                                         |
//+------------------------------------------------------------------+
int CalculateCurrentOrders(string symbol)
  {
   int buys=0,sells=0;
//----
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(OrderSymbol()==symbol && OrderMagicNumber()==MAGICMA)
        {
         if(OrderType()==OP_BUY)  buys++;
         if(OrderType()==OP_SELL) sells++;
        }
     }
//---- return orders volume
   if(buys>0) return(buys);
   else       return(-sells);
  }
//+------------------------------------------------------------------+
//| Calculate optimal lot size                                       |
//+------------------------------------------------------------------+
double LotsOptimized()
  {
   double lot=Lots;
/*
   if(profit<-180*c){
     //lot=(lot*2);
   }*/
   return(lot);
  }
//+------------------------------------------------------------------+
//| Check for open order conditions                                  |
//+------------------------------------------------------------------+
void CheckForOpen()
  {
   double ma;
    double ma2;
   int    res;
   double MacdCurrent, MacdPrevious, SignalCurrent;
double SignalPrevious, MaCurrent, MaPrevious;
//---- go trading only for first tiks of new bar
//---- get Moving Average 
  
  
   MacdCurrent=iMACD(NULL,0,fast_ema_period,slow_ema_period,signal_period,PRICE_WEIGHTED,MODE_MAIN,0);//柱高
   MacdPrevious=iMACD(NULL,0,fast_ema_period,slow_ema_period,signal_period,PRICE_WEIGHTED,MODE_MAIN,1);
   SignalCurrent=iMACD(NULL,0,fast_ema_period,slow_ema_period,signal_period,PRICE_WEIGHTED,MODE_SIGNAL,0);//线指标
   SignalPrevious=iMACD(NULL,0,fast_ema_period,slow_ema_period,signal_period,PRICE_WEIGHTED,MODE_SIGNAL,1);
   double MacdPrevious2=iMACD(NULL,0,fast_ema_period,slow_ema_period,signal_period,PRICE_WEIGHTED,MODE_MAIN,2);
   double  SignalPrevious2=iMACD(NULL,0,fast_ema_period,slow_ema_period,signal_period,PRICE_WEIGHTED,MODE_SIGNAL,2);
    double MacdPrevious3=iMACD(NULL,0,fast_ema_period,slow_ema_period,signal_period,PRICE_WEIGHTED,MODE_MAIN,3);
  double  SignalPrevious3=iMACD(NULL,0,fast_ema_period,slow_ema_period,signal_period,PRICE_WEIGHTED,MODE_SIGNAL,3);
  //double SignalM=iMACD(NULL,0,fast_ema_period,slow_ema_period,8,PRICE_WEIGHTED,MODE_SIGNAL,0);//线指标
   ShiftValue = getShiftValue();
    // ShiftValue=0;
   if(ShiftValue==0&&MacdPrevious<SignalPrevious&&(MacdPrevious2>=SignalPrevious2||MacdPrevious3>=SignalPrevious3))
   {
      res=OrderSend(Symbol(),OP_SELL,LotsOptimized(),Bid,30,0,0,"",MAGICMA,0,Red);
      OrderModify(res,Bid,Bid+StopLoss*Point,Bid-TrailingStop*Point,0,Red);
    }else
   if(ShiftValue==0&&MacdPrevious>SignalPrevious&&(MacdPrevious2<=SignalPrevious2||MacdPrevious3<=SignalPrevious3))  
   {
      res=OrderSend(Symbol(),OP_BUY,LotsOptimized(),Ask,30,0,0,"",MAGICMA,0,Blue);
      OrderModify(res,Ask,Ask-StopLoss*Point,Ask+TrailingStop*Point,0,Blue);
   }

//----
  }
//+------------------------------------------------------------------+
//| Check for close order conditions                                 |
//+------------------------------------------------------------------+
void CheckForClose()
  {
  double ma;
    double ma2;
   int res;
   double profit1;
      double MacdCurrent, MacdPrevious, SignalCurrent;
double SignalPrevious, MaCurrent, MaPrevious;
//---- go trading only for first tiks of new bar
   
//---- get Moving Average 
   
   MacdCurrent=iMACD(NULL,0,fast_ema_period,slow_ema_period,signal_period,PRICE_WEIGHTED,MODE_MAIN,0);//柱高
   MacdPrevious=iMACD(NULL,0,fast_ema_period,slow_ema_period,signal_period,PRICE_WEIGHTED,MODE_MAIN,1);
   SignalCurrent=iMACD(NULL,0,fast_ema_period,slow_ema_period,signal_period,PRICE_WEIGHTED,MODE_SIGNAL,0);//线指标
   SignalPrevious=iMACD(NULL,0,fast_ema_period,slow_ema_period,signal_period,PRICE_WEIGHTED,MODE_SIGNAL,1);
   
   
//----
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)        break;
      if(OrderMagicNumber()!=MAGICMA || OrderSymbol()!=Symbol()) continue;
      //---- check order type 
     
      if(TimeCurrent()-OrderOpenTime()<10*60){
         continue;
      }
      if(OrderType()==OP_BUY)
        {
         if(MacdPrevious<SignalPrevious) {
         OrderClose(OrderTicket(),OrderLots(),Bid,30,White);
         }
         break;
        }
        if(OrderType()==OP_SELL)
        {
         if(MacdPrevious>SignalPrevious) {
            OrderClose(OrderTicket(),OrderLots(),Ask,30,White);
         }
         
         break;
        }
     }
//----
  }
//+------------------------------------------------------------------+
//| Start function                                                   |
//+------------------------------------------------------------------+
void start()
  {
//---- check for history and trading
   //if(Bars<100 || IsTradeAllowed()==false) return;
//---- calculate open orders by current symbol
   
   if(Volume[0]>100) return;
   if(CalculateCurrentOrders(Symbol())==0) {
  
   CheckForOpen();
   }else{
   CheckForClose();
   }
//----
  }
int init()
  {
//----
   //if(ShiftValue>=0){
    //  ShiftValue = getShiftValue();
 //  }
  // Print("init() ShiftValue=====",ShiftValue);
    // 来自交易历史的恢复信息
  int i,hstTotal=OrdersHistoryTotal();
  for(i=0;i<hstTotal;i++)
    {
     //---- 检查选择结果
     if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==false)
       {
        Print("带有 (",GetLastError(),")错误的历史失败通道");
        break;
       }
       if(OrderSymbol()!=Symbol()||OrderMagicNumber()!=MAGICMA ) continue;
        profit+=OrderProfit();
        if(profit>0){
         profit=0;
        }
  }
   Print("init()",profit);
//----
   return(0);
  }
int getShiftValue()
{

   int v=0;
   double value=0;
   
   for(int i = col;i>=0;i--)
   {
       value=iMACD(NULL,0,fast_ema_period,slow_ema_period,signal_period,PRICE_WEIGHTED,MODE_MAIN,i);//柱高
       if(value>ifv){
         v=1;
       }
       if(value<0-ifv){
         v=1;
       }
   }
   Print("v=====",v);
   return(v);
}
//+------------------------------------------------------------------+