//+------------------------------------------------------------------+
//|                                                  ADV_nk_GBPUSD_H1_v008.mq4 |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "zeng jin"
#include <advlib.mqh>
#define MAGICMA  10002

extern double  Lots               = 0.2;
extern int     NK               = 14;

extern int     gap=60; //相差点数;
extern int     TrailingStop = 3000;
extern int     StopLoss = 5000;

extern bool DoesOverweight=true; //是否加码

extern int     stdDevShift=30;
extern int     stdDev_ma_period=50;
extern double  ifStdDevV = 0.007;


extern double profit = 0;

//+------------------------------------------------------------------+
//| Check for open order conditions                                  |
//+------------------------------------------------------------------+
void CheckForOpen()
  {
//----

     int    res;
     double ilow = getiLowVByNK(Symbol(),NULL,NK);
     double ihigh = getiHighVByNK(Symbol(),NULL,NK);
     int LastOrderType =-1;
     double stdDevMax = getStdDevMaxValue(stdDevShift,stdDev_ma_period);
    // Print("stdDevMax==",stdDevMax);
     if(stdDevMax>ifStdDevV){
    // Print("stdDevMax==",stdDevMax);
      return;
     }else{
    //  Print("NO  stdDevMax==",stdDevMax);
     }
     
     
     
     if(Ask<(ilow-gap*Point))  
     {
         //if(getShiftValue(OP_SELL)==0){
            res=AdvOrderSend(Symbol(),OP_SELL,LotsOptimized(),Bid,30,Bid+StopLoss*Point,Bid-TrailingStop*Point,"",MAGICMA,0,Red);
            return;
        // }
     }
     else if(Ask>(ihigh+gap*Point)){
      //if(getShiftValue(OP_BUY)==0){
         res=AdvOrderSend(Symbol(),OP_BUY,LotsOptimized(),Ask,30,Ask-StopLoss*Point,Ask+TrailingStop*Point,"",MAGICMA,0,Blue);
         return;
      //  }
     }
//----
  }

  
  
//+------------------------------------------------------------------+
//| Check for close order conditions                                 |
//+------------------------------------------------------------------+
void CheckForClose()
  {
//----

      int    res;
      double ilow = getiLowVByNK(Symbol(),NULL,NK);
     double ihigh = getiHighVByNK(Symbol(),NULL,NK);
     for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)        break;
      if(OrderMagicNumber()!=MAGICMA || OrderSymbol()!=Symbol()) continue;
      //---- check order type 
      if(OrderType()==OP_BUY)
        {
         if(Ask<(ilow-gap*Point)){
            OrderClose(OrderTicket(),OrderLots(),Bid,30,White);
            break;
         }
          if(TimeCurrent()-OrderOpenTime()>60*60){
              OrderModify(OrderTicket(),Bid,ilow-(gap+60)*Point,OrderTakeProfit(),0,CLR_NONE);
           }
                 break;
        }
      if(OrderType()==OP_SELL)
        {
         if(Ask>(ihigh+gap*Point)){
            OrderClose(OrderTicket(),OrderLots(),Ask,30,White);
            break;
         }
         if(TimeCurrent()-OrderOpenTime()>60*60){
             OrderModify(OrderTicket(),Ask,ihigh+(gap+30)*Point,OrderTakeProfit(),0,CLR_NONE);
         }
       
         break;
        }
     }
//----
  }

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
  
      

   if(profit<(-700)*(Lots/0.1)){
   lot = 0.3*(Lots/0.1);
   }else if(profit<(-200)*(Lots/0.1)){
   lot = 0.2*(Lots/0.1);
   }
  // lot=0.1;
   return(lot);
  } 





//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
 {
   //if(Volume[0]>10) return;
   
   if(CalculateCurrentOrders(Symbol(),MAGICMA)==0) {
  
  //if(Hour()<16&&Hour()>7){   //北京时间Hour()<04&&Hour()>10
     CheckForOpen();
   //  }
  }else{
  
   CheckForClose();
  }
  //if(IsTesting()){
  // Sleep(50000);
 // }

 }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
{ 
  // double v1 = setHisProfitF(MAGICMA,292.3);
   if(profit==0){
      profit = getHisProfitV(MAGICMA);
     }
   Print("init()  profit == ",profit);
   Print("init() OK..");
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
  
int getShiftValue(int otype)
{

   int v=0;
   int col = 50;
   double value=0;

     
   if(otype==-1){
   return(-1);
   }  
   else if(otype==OP_SELL){
     
      for(int i = 1;i<col;i++)
      {
         double ch1 = iHigh(Symbol(),NULL,i);
         double h1 = getiHighVByNKA(Symbol(),NULL,NK,i+1);
         
         if(ch1>(h1+gap*Point)){
            v= i;
            i=col;
         }
         
      }
      
     for( i = v;i>0;i--){
          double cl1 = iLow(Symbol(),NULL,i);  
          double l1 = getiLowVByNKA(Symbol(),NULL,NK,i+1);
          if(cl1<(l1-gap*Point)){
            value=l1;
            i=0;
          }
     }
     
     if(Ask>(value-500*Point)){
          return(0);
     }
   }
    else if(otype==OP_BUY){
     
      for( i = 1;i<col;i++)
      {
         double cl2 = iLow(Symbol(),NULL,i);
         double l2 = getiLowVByNKA(Symbol(),NULL,NK,i+1);
         
         if(cl2<(l2-gap*Point)){
            v= i;
            i=col;
         }
         
      }
      
     for( i = v;i>0;i--){
          double ch2 = iHigh(Symbol(),NULL,i);  
          double h2 = getiHighVByNKA(Symbol(),NULL,NK,i+1);
          if(ch2>(h2+gap*Point)){
            value=h2;
            i=0;
          }
     }
     
     if(Ask<(value+500*Point)){
          return(0);
     }
   }
   
   
   //Print("value=====",value);
   return(-1);
}  

/**
获取前N根K的最高值.
*/
double getiHighVByNKA(string symbol, int timeframe , int nk,int a)
{ 
    double h1 = iHigh(symbol,timeframe,a);

     for(int i=a;i<=a+nk;i++){
         if(iHigh(symbol,timeframe,i)>h1){
           h1=iHigh(symbol,timeframe,i);
         }
     }
     return(h1);
}

/**
获取前N根K的最低值.
*/
double getiLowVByNKA(string symbol, int timeframe , int nk, int a)
{ 
    double l1 = iLow(symbol,timeframe,a);

     for(int i=a ;i<=a+nk;i++){
         if(iLow(symbol,timeframe,i)<l1){
           l1=iLow(symbol,timeframe,i);
         }
     }
     return(l1);
}

