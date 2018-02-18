//+------------------------------------------------------------------+
//|                                          ADV_MACD_EURJPY_M30_v118.mq4 |
//|                                                         zeng jin |
//+------------------------------------------------------------------+
#property copyright "zeng jin"
#define MAGICMA  20001
#include <advlib.mqh>
extern double Lots               = 0.1;

extern double MaximumRisk        = 1;

extern int fast_ema_period=22;
extern int slow_ema_period=44;
extern int signal_period=35;


extern bool DoesOverweight=true; //是否加码

extern int     stdDevShift=150;
extern int     stdDev_ma_period=27;
extern double  ifStdDevV = 0.62;

extern double profit             =0;


extern double TrailingStop = 500;
extern double StopLoss = 500;

extern int  ExitVolume=100;

//+------------------------------------------------------------------+
//| Calculate open positions                                         |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Calculate optimal lot size                                       |
//+------------------------------------------------------------------+
double LotsOptimized()
  {
  double lot=Lots;
   if(!DoesOverweight){
   return(lot);
   }
  //int    orders=HistoryTotal();     // history orders total
 //  int    losses=0;                  // number of losses orders without a break
//---- select lot size
  // lot=NormalizeDouble(AccountFreeMargin()*MaximumRisk/1000.0,1);
//---- calcuulate number of losses orders without a break


   if(OrderSelect(OrdersHistoryTotal()-1,SELECT_BY_POS,MODE_HISTORY)==false) { Print("Error in history!");  }
   if(OrderSymbol()!=Symbol() ||OrderMagicNumber()!=MAGICMA  || OrderType()>OP_SELL){
   }else{
   profit+=OrderProfit();
   if(profit>0){
    profit=0;
   }
   }
   
         //if(OrderProfit()>0) losses++;
        
     // if(losses>1) lot=NormalizeDouble(lot-lot*losses/DecreaseFactor,1);
   
     Print("profit",profit);

//---- return lot size
  // if(lot<0.1) lot=0.1;

   lot=Lots;
      
         /*
            if(profit<-1&&(profit/(-900))>1){
         int l = NormalizeDouble((profit/(-300)),0);
         if(l>0){
            lot=(lot*l);
            }
      }else if(profit<-1&&(profit/(-220))>1){
          l = NormalizeDouble((profit/(-220)),0);
         if(l>0){
            lot=(lot*l);
            }
      }
      */
    //  profit = profit/c;
    
     
     if(profit<-1500*MaximumRisk){
   lot = 0.3*MaximumRisk;
   }else if(profit<-600*MaximumRisk){
   lot = 0.2*MaximumRisk;
   }else  if(profit<-300*MaximumRisk){
   lot = 0.18*MaximumRisk;
   }else 
      if(profit<-250*MaximumRisk){
   lot = 0.16*MaximumRisk;
   }else 
   if(profit<-200*MaximumRisk){
   lot = 0.16*MaximumRisk;
   }else if(profit<-150*MaximumRisk){
   lot = 0.14*MaximumRisk;
   }else if(profit<-100*MaximumRisk){
   lot = 0.12*MaximumRisk;
   }else if(profit<-50*MaximumRisk){
   lot = 0.11*MaximumRisk;
   } 
   
   // lot=lot*c;
  /* if(AccountBalance()>800){
   lot = lot*NormalizeDouble((AccountBalance()/800),0);
   }else{
   }*/
   //Print("NormalizeDouble((AccountBalance()/500),1)=======================================",NormalizeDouble((AccountBalance()/500),1));
 /*
  if(lot>0.1)
  {
   lot = lot+(c-1);
  }*/
  // lot=0.1;
  
  lot=NormalizeDouble(lot,2);
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
   //ShiftValue = getShiftValue();

    double stdDevMax = getStdDevMaxValue(stdDevShift,stdDev_ma_period);
    // Print("stdDevMax==",stdDevMax);
     if(stdDevMax>ifStdDevV){
    // Print("stdDevMax==",stdDevMax);
      return;
     }else{
    //  Print("NO  stdDevMax==",stdDevMax);
     }
    // ShiftValue=0;
   if(MacdPrevious<SignalPrevious&&(MacdPrevious2>=SignalPrevious2||MacdPrevious3>=SignalPrevious3))
   {
      res=AdvOrderSend(Symbol(),OP_SELL,LotsOptimized(),Bid,3,Bid+StopLoss*Point,Bid-TrailingStop*Point,"",MAGICMA,0,Color_OP_SELL_Order);
      //OrderModify(res,Bid,Bid+StopLoss*Point,Bid-TrailingStop*Point,0,Red);
    }else
   if(MacdPrevious>SignalPrevious&&(MacdPrevious2<=SignalPrevious2||MacdPrevious3<=SignalPrevious3))  
   {
      res=AdvOrderSend(Symbol(),OP_BUY,LotsOptimized(),Ask,3,Ask-StopLoss*Point,Ask+TrailingStop*Point,"",MAGICMA,0,Color_OP_BUY_Order);
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
         if(MacdPrevious<SignalPrevious) {
            bool isc = OrderClose(OrderTicket(),OrderLots(),Bid,3,Color_CLOSE_Order);
             if(isc){
               CheckForOpen();
            }
         }
         break;
        }
        if(OrderType()==OP_SELL)
        {
         if(MacdPrevious>SignalPrevious) {
             bool isc1 =OrderClose(OrderTicket(),OrderLots(),Ask,3,Color_CLOSE_Order);
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
   
   if(Volume[0]>ExitVolume) return;
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
  profit=getHisProfitV(MAGICMA);
//----
   return(0);
  }

//+------------------------------------------------------------------+