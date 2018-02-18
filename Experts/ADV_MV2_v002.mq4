#property copyright "ZNEGJIN"

#include <advlib.mqh>

#define MAGICMA  20100210
extern double Lots               = 0.1;
extern double MaximumRisk        = 0.02;
extern double DecreaseFactor     = 3;
extern double MovingPeriod       = 13;
extern double MovingPeriod2       = 21;
extern double MovingShift        = 0;
extern double profit             =0;
extern int    per = 14;
extern int    MaxSafety =10000;    //±£ÏÕÖ¸Êý
extern double TrailingStop = 10000;
extern double StopLoss = 10000;





double LotsOptimized()
  {
   return(Lots);
  }
//+------------------------------------------------------------------+
//| Check for open order conditions                                  |
//+------------------------------------------------------------------+
void CheckForOpen()
  {
   double ma;
    double ma2;
   int    res;
//---- go trading only for first tiks of new bar
//---- get Moving Average 
   ma=iMA(NULL,0,MovingPeriod,MovingShift,MODE_SMA,PRICE_WEIGHTED,0);
   ma2=iMA(NULL,0,MovingPeriod2,MovingShift,MODE_SMA,PRICE_WEIGHTED,0);
  double ma_3=iMA(NULL,0,MovingPeriod,MovingShift,MODE_SMA,PRICE_WEIGHTED,3);
  double ma2_3=iMA(NULL,0,MovingPeriod2,MovingShift,MODE_SMA,PRICE_WEIGHTED,3);
  double ma_1=iMA(NULL,0,MovingPeriod,MovingShift,MODE_SMA,PRICE_WEIGHTED,1);
  double ma2_1=iMA(NULL,0,MovingPeriod2,MovingShift,MODE_SMA,PRICE_WEIGHTED,1);
  double ma_2=iMA(NULL,0,MovingPeriod,MovingShift,MODE_SMA,PRICE_WEIGHTED,2);
  double ma2_2=iMA(NULL,0,MovingPeriod2,MovingShift,MODE_SMA,PRICE_WEIGHTED,2);
   if(ma<ma2&&(ma_3>=ma2_3||ma_1>=ma2_1||ma_2>=ma2_2))
     {
      res=AdvOrderSend(Symbol(),OP_SELL,LotsOptimized(),Bid,30,Bid+StopLoss*Point,Bid-TrailingStop*Point,"",MAGICMA,0,Color_OP_SELL_Order);
     }
//---- buy conditions
   if(ma>ma2&&(ma_3<=ma2_3||ma_1<=ma2_1||ma_2<=ma2_2))  
   {
      res=AdvOrderSend(Symbol(),OP_BUY,LotsOptimized(),Ask,30,Ask-StopLoss*Point,Ask+TrailingStop*Point,"",MAGICMA,0,Color_OP_BUY_Order);
     
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
//---- go trading only for first tiks of new bar
   
//---- get Moving Average 
   ma=iMA(NULL,0,MovingPeriod,MovingShift,MODE_SMA,PRICE_WEIGHTED,0);
   ma2=iMA(NULL,0,MovingPeriod2,MovingShift,MODE_SMA,PRICE_WEIGHTED,0);
//----
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)        break;
      if(OrderMagicNumber()!=MAGICMA || OrderSymbol()!=Symbol()) continue;
      //---- check order type 
     
      if(TimeCurrent()-OrderOpenTime()<20*60){
     continue;
      }
      if(OrderType()==OP_BUY)
        {
         if(ma<ma2) {
         OrderClose(OrderTicket(),OrderLots(),Bid,30,Color_CLOSE_Order);
         }
          break;
        }
      if(OrderType()==OP_SELL)
        {
         if(ma>ma2) {
            OrderClose(OrderTicket(),OrderLots(),Ask,30,Color_CLOSE_Order);
         }
         break;
        }
     }
//----
  }

//+------------------------------------------------------------------+
void start()
  {
//---- check for history and trading
   //if(Bars<100 || IsTradeAllowed()==false) return;

   if(Volume[0]>20) return;
   if(CalculateCurrentOrders(Symbol(),MAGICMA)==0) CheckForOpen();else
   CheckForClose();
//----
  }
int init()
  {
//----
   return(0);
  }



