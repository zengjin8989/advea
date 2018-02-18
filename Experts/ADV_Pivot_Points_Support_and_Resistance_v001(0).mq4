//+------------------------------------------------------------------+
//|                                                          zengjin |
//+------------------------------------------------------------------+
#property copyright "zengjin"
#define MAGICMA  20090502
extern double Lots               = 0.1;
extern double MaximumRisk        = 0.02;
extern double DecreaseFactor     = 3;
extern double MovingPeriod       = 13;
extern double MovingPeriod2       = 21;
extern double MovingShift        = 0;
extern double profit             =0;
extern int    per = 14;
extern double TrailingStop = 10000;
extern double StopLoss = 1200;
extern int MAC = 2;
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
  
double getBigMAC(){
   double mac0 = iMA(NULL,PERIOD_H4,15,MovingShift,MODE_SMA,PRICE_CLOSE,0);
   double mac1 = iMA(NULL,PERIOD_H4,15,MovingShift,MODE_SMA,PRICE_CLOSE,1);
   double mac2 = iMA(NULL,PERIOD_H4,15,MovingShift,MODE_SMA,PRICE_CLOSE,2);
   
   
   double macV = mac0-mac1;
   macV = mac0-mac2+macV;
   
   double high1 = iHigh(NULL,PERIOD_D1,1);
   double high2 = iHigh(NULL,PERIOD_D1,2);
   double low1 = iLow(NULL,PERIOD_D1,1);
   double low2 = iLow(NULL,PERIOD_D1,2);
   double highV = high1-high2;
   double lowV = low1-low2;
   
   double h1 = iHigh(NULL,PERIOD_H4,1);
   int i =2 ;
     for( ;i<10;i++){
         if(iHigh(NULL,PERIOD_H4,i)>h1){
           h1=iHigh(NULL,PERIOD_H4,i);
         }
     }
   double h2 = iHigh(NULL,PERIOD_H4,i);
     for(; i<19;i++){
         if(iHigh(NULL,PERIOD_H4,i)>h2){
           h2=iHigh(NULL,PERIOD_H4,i);
         }
     }
     
      double l1 = iLow(NULL,PERIOD_H4,1);
  i =2 ;
     for( ;i<10;i++){
         if(iLow(NULL,PERIOD_H4,i)<h1){
           h1=iLow(NULL,PERIOD_H4,i);
         }
     }
   double l2 = iLow(NULL,PERIOD_H4,i);
     for(; i<19;i++){
         if(iLow(NULL,PERIOD_H4,i)<h2){
           h2=iLow(NULL,PERIOD_H4,i);
         }
     }
     
    highV = h1-h2;
  lowV = l1-l2;
  
   if(highV>0&&lowV>0)
   {
      return(1);
   }
   if(highV<0&&lowV<0){
      return(-1);
   }
  if(highV>0){
     if(highV*(-1)<lowV)
     {
       return(1);
     }
     else{
       return(0);
     }
  }
  if(lowV>0)
  {
      if(lowV*(-1)<highV)
     {
       return(1);
     }
     else{
       return(0);
     }
  }
  
   return(0);
} 
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
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==MAGICMA)
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
   int    orders=HistoryTotal();     // history orders total
   int    losses=0;                  // number of losses orders without a break
//---- select lot size
   lot=NormalizeDouble(AccountFreeMargin()*MaximumRisk/1000.0,1);
//---- calcuulate number of losses orders without a break
   if(DecreaseFactor>0)
     {
      for(int i=orders-1;i>=0;i--)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==false) { Print("Error in history!"); break; }
         if(OrderSymbol()!=Symbol() || OrderType()>OP_SELL) continue;
         //----
         //if(OrderProfit()<0) 
       
         profit+=OrderProfit();
         if(profit>0){
         profit=0;
         }
         break;
         //if(OrderProfit()>0) losses++;
        }
     // if(losses>1) lot=NormalizeDouble(lot-lot*losses/DecreaseFactor,1);
     }
     Print("profit",profit);
//---- return lot size
  // if(lot<0.1) lot=0.1;
  int c=1;
   if((AccountBalance()/1500)>1)
   {
   // c=NormalizeDouble((AccountBalance()/1500),1);
  }
   lot=0.1;
   if(profit<-180){
   //lot=lot+0.1;
   }
   //if(profit<-1000*c){
  // lot=lot+0.7;
   //}
   
  
   
  /* if(AccountBalance()>800){
   lot = lot*NormalizeDouble((AccountBalance()/800),0);
   }else{
   }*/
   //Print("NormalizeDouble((AccountBalance()/500),1)=======================================",NormalizeDouble((AccountBalance()/500),1));
 
  
  /*if(lot>0.1)
  {
  lot = lot+(c-1);
  }
   lot=0.1;*/
   
   return(lot*c);
  }
//+------------------------------------------------------------------+
//| Check for open order conditions                                  |
//+------------------------------------------------------------------+
void CheckForOpen()
  {
   double ma;
    double ma2;
    double MacdCurrent, MacdPrevious, SignalCurrent;
double SignalPrevious, MaCurrent, MaPrevious;
   int    res;
//---- go trading only for first tiks of new bar
   if(Volume[0]>2) return;
//---- get Moving Average 
   ma=iMA(NULL,0,MovingPeriod,MovingShift,MODE_SMA,PRICE_CLOSE,0);
   ma2=iMA(NULL,0,MovingPeriod2,MovingShift,MODE_SMA,PRICE_CLOSE,0);
   
  double ma_1=iMA(NULL,0,MovingPeriod,MovingShift,MODE_SMA,PRICE_CLOSE,1);
  double ma2_1=iMA(NULL,0,MovingPeriod2,MovingShift,MODE_SMA,PRICE_CLOSE,1);
   
   MacdCurrent=iMACD(NULL,0,8,13,9,PRICE_CLOSE,MODE_MAIN,0);//柱高
MacdPrevious=iMACD(NULL,0,8,13,9,PRICE_CLOSE,MODE_MAIN,1);
SignalCurrent=iMACD(NULL,0,8,13,9,PRICE_CLOSE,MODE_SIGNAL,0);//线指标
SignalPrevious=iMACD(NULL,0,8,13,9,PRICE_CLOSE,MODE_SIGNAL,1);
//---- sell conditions
  // double  ADX = iADX(NULL, 0, per, PRICE_WEIGHTED, MODE_MAIN, 0);
 //  double  ADX1 = iADX(NULL, 0, per, PRICE_WEIGHTED, MODE_MAIN, 1);
//if(ADX>ADX1&&ADX>25){
   int type = -1;
   if(OrderSelect(OrdersHistoryTotal()-1,SELECT_BY_POS,MODE_HISTORY)==true)
   {
  //type = OrderType();
   }
   double macV = getBigMAC();
    
   if(ma<ma2&&(type==OP_BUY||type==-1)&&macV<0&&(ma_1>=ma2_1))  
     {
      //if(Hour()>=1&&Hour()<17)
      Print("SmacV=",macV);
      res=OrderSend(Symbol(),OP_SELL,LotsOptimized(),Bid,30,Bid+StopLoss*Point,Bid-TrailingStop*Point,"",MAGICMA,0,Red);
      return;
     }
//---- buy conditions
   if(ma>ma2&&(type==OP_SELL||type==-1)&&macV>0&&(ma_1<=ma2_1))  
     {
     //if(Hour()>=1&&Hour()<17)
     Print("BmacV=",macV);
      res=OrderSend(Symbol(),OP_BUY,LotsOptimized(),Ask,30,Ask-StopLoss*Point,Ask+TrailingStop*Point,"",MAGICMA,0,Blue);
      return;
     }
    //}
//----
  }
//+------------------------------------------------------------------+
//| Check for close order conditions                                 |
//+------------------------------------------------------------------+
void CheckForClose()
  {
  double ma;
    double ma2;
        double MacdCurrent, MacdPrevious, SignalCurrent;
double SignalPrevious, MaCurrent, MaPrevious;
   int res;
//---- go trading only for first tiks of new bar
   if(Volume[0]>2) return;
//---- get Moving Average 
   ma=iMA(NULL,0,MovingPeriod,MovingShift,MODE_SMA,PRICE_CLOSE,0);
   ma2=iMA(NULL,0,MovingPeriod2,MovingShift,MODE_SMA,PRICE_CLOSE,0);
//----
MacdCurrent=iMACD(NULL,0,8,13,9,PRICE_CLOSE,MODE_MAIN,0);//柱高
MacdPrevious=iMACD(NULL,0,8,13,9,PRICE_CLOSE,MODE_MAIN,1);
SignalCurrent=iMACD(NULL,0,8,13,9,PRICE_CLOSE,MODE_SIGNAL,0);//线指标
SignalPrevious=iMACD(NULL,0,8,13,9,PRICE_CLOSE,MODE_SIGNAL,1);
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)        break;
      if(OrderMagicNumber()!=MAGICMA || OrderSymbol()!=Symbol()) continue;
      //---- check order type 
      if(OrderType()==OP_BUY)
        {
         if(ma<ma2) {
         OrderClose(OrderTicket(),OrderLots(),Bid,30,White);
        // if(Hour()>=1&&Hour()<17)
         //res=OrderSend(Symbol(),OP_SELL,LotsOptimized(),Bid,3,Bid+StopLoss*Point,Bid-TrailingStop*Point,"",MAGICMA,0,Red);
         }
         
         if(Bid-OrderOpenPrice()>300*Point&&Close[1]<ma2){
          Print("OrderOpenPrice()==",OrderOpenPrice());
            OrderClose(OrderTicket(),OrderLots(),Ask,3,White);
         }
         break;
        }
      if(OrderType()==OP_SELL)
        {
         if(ma>ma2) {
         OrderClose(OrderTicket(),OrderLots(),Ask,30,White);
         //if(Hour()>=1&&Hour()<17)
        //res=OrderSend(Symbol(),OP_BUY,LotsOptimized(),Ask,3,Ask-StopLoss*Point,Ask+TrailingStop*Point,"",MAGICMA,0,Blue);
         }
         
         if(OrderOpenPrice()-Ask>300*Point&&Close[1]>ma2){
            Print("OrderOpenPrice()==",OrderOpenPrice());
            OrderClose(OrderTicket(),OrderLots(),Ask,3,White);
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
   if(CalculateCurrentOrders(Symbol())==0) CheckForOpen();
   else                                    CheckForClose();
//----
  }
//+------------------------------------------------------------------+