//+------------------------------------------------------------------+
//|                                          ADV_MACD_EURUSD_M30_v038.mq4 |
//|                                                         zeng jin |
//+------------------------------------------------------------------+
#property copyright "zeng jin"
#define MAGICMA  10001
#include <advlib.mqh>
extern double Lots               = 0.1;

extern int fast_ema_period=26;
extern int slow_ema_period=52;
extern int signal_period=43;

extern int     stdDevShift=150;
extern int     stdDev_ma_period=28;
extern double  ifStdDevV = 0.006;

extern bool DoesOverweight=true; //是否加码

extern double profit             =0;

extern double TrailingStop = 5000;
extern double StopLoss = 1500;



//+------------------------------------------------------------------+
//| Calculate optimal lot size                                       |
//+------------------------------------------------------------------+
double LotsOptimized()
  {
  double lot=Lots;
   if(!DoesOverweight){
   return(lot);
   }
   
    profit+=getHisProfitLV(MAGICMA);
   if(profit>0){
    profit=0;
   }
   
         //if(OrderProfit()>0) losses++;
        
     // if(losses>1) lot=NormalizeDouble(lot-lot*losses/DecreaseFactor,1);
   
     Print("profit=",profit);


  int c=1;
   if(profit<(Lots/0.1)*(-5000)){
   lot = 1.5*(Lots/0.1);
   }else
      
   if(profit<(Lots/0.1)*(-2800)){
      lot = 1.1*(Lots/0.1);
   }else if(profit<(Lots/0.1)*(-1600)){
      lot = 0.8*(Lots/0.1);
   }else if(profit<(Lots/0.1)*(-700)){
      lot = 0.5*(Lots/0.1);
   }else if(profit<(Lots/0.1)*(-300)){
      lot = 0.3*(Lots/0.1);
   }else if(profit<(Lots/0.1)*(-90)){
      lot = 0.2*(Lots/0.1);
   } 
   if(lot>0.3*(Lots/0.1)){
    //lot=0.3*(Lots/0.1);
   }
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
 //   double MacdPrevious3=iMACD(NULL,0,fast_ema_period,slow_ema_period,signal_period,PRICE_WEIGHTED,MODE_MAIN,3);
 // double  SignalPrevious3=iMACD(NULL,0,fast_ema_period,slow_ema_period,signal_period,PRICE_WEIGHTED,MODE_SIGNAL,3);
  //double SignalM=iMACD(NULL,0,fast_ema_period,slow_ema_period,8,PRICE_WEIGHTED,MODE_SIGNAL,0);//线指标
   //ShiftValue = getShiftValue();

    double stdDevMax = getStdDevMaxValue(stdDevShift,stdDev_ma_period);
     Print("stdDevMax==",stdDevMax);
     if(stdDevMax>ifStdDevV){
     Print("stdDevMax==",stdDevMax);
      return;
     }else{
    //  Print("NO  stdDevMax==",stdDevMax);
     }
    // ShiftValue=0;
   if(MacdCurrent<SignalCurrent&&(MacdPrevious2>=SignalPrevious2||MacdPrevious>=SignalPrevious))
   {
      res=AdvOrderSend(Symbol(),OP_SELL,LotsOptimized(),Bid,30,Bid+StopLoss*Point,Bid-TrailingStop*Point,"",MAGICMA,0,Color_OP_SELL_Order);
      //OrderModify(res,Bid,Bid+StopLoss*Point,Bid-TrailingStop*Point,0,Red);
    }else
   if(MacdCurrent>SignalCurrent&&(MacdPrevious2<=SignalPrevious2||MacdPrevious<=SignalPrevious))  
   {
      res=AdvOrderSend(Symbol(),OP_BUY,LotsOptimized(),Ask,30,Ask-StopLoss*Point,Ask+TrailingStop*Point,"",MAGICMA,0,Color_OP_BUY_Order);
     // OrderModify(res,Ask,Ask-StopLoss*Point,Ask+TrailingStop*Point,0,Blue);
   }

//----
  }
//+------------------------------------------------------------------+
//| Check for close order conditions                                 |
//+------------------------------------------------------------------+
void CheckForClose()
  {

   int res;

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
         if(MacdCurrent<SignalCurrent) {
            bool isc = OrderClose(OrderTicket(),OrderLots(),Bid,30,Color_CLOSE_Order);
            if(isc){
               CheckForOpen();
            }
         }
         break;
        }
        if(OrderType()==OP_SELL)
        {
         if(MacdCurrent>SignalCurrent) {
            bool isc1 = OrderClose(OrderTicket(),OrderLots(),Ask,30,Color_CLOSE_Order);
            if(isc1){
               CheckForOpen();
            }
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
   
   if(Minute()>=30&&Minute()<57) return;
   if(Minute()>=0&&Minute()<27) return;
   if(CalculateCurrentOrders(Symbol(),MAGICMA)==0) {
  
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
    if(profit==0){
      profit = getHisProfitV(MAGICMA);
     }
      Print("init()  profit == ",profit);
     Print("init() OK..");
//----
   return(0);
  }

//+------------------------------------------------------------------+