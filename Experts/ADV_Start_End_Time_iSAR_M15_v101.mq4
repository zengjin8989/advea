//+------------------------------------------------------------------+
//|                              ADV_Start_End_Time_iSAR_M15_v101.mq4 |
//|                                                         zeng jin |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "zeng jin"

#include <advlib.mqh>
 
#define MAGICMA  520180313

extern double Lots               = 1;
extern double step=0.02;
extern double maximum=0.2;
extern int StartTime1=100000;
extern int EndTime1=100000;
extern int StartTime2=100000;
extern int EndTime2=100000;
extern int StartTime3=100000;
extern int EndTime3=100000;
extern double TrailingStop = 50000;
extern double StopLoss = 25000;

extern int startHourTime=0;

extern bool DoesOverweight=true; //是否加码

extern double profit             =0;
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
   
    profit+=getHisProfitLV(MAGICMA);
   if(profit>0){
    profit=0;
   }
   
         //if(OrderProfit()>0) losses++;
        
     // if(losses>1) lot=NormalizeDouble(lot-lot*losses/DecreaseFactor,1);
   
     Print("profit=",profit);


  int c=1;
     
   if(profit<(Lots)*(-240)){
      lot =4*Lots;
   }else if(profit<(Lots)*(-88)){
      lot =3*Lots;
   }else if(profit<(Lots)*(-44)){
      lot = 2*Lots;
   }else if(profit<(Lots)*(-24)){
      lot =1.5*Lots;
   }else if(profit<(Lots)*(-12)){
      lot = 1.2*Lots;
   } 
   return(lot);
  }
//+------------------------------------------------------------------+
//| Check for open order conditions                                  |
//+------------------------------------------------------------------+
void CheckForOpen()
  {
  
   int    res;
//---- go trading only for first tiks of new bar

 double isarV0 =  iSAR(NULL,0,step,maximum,0);
  //Print("isarV0="+isarV0);
  
   if(Ask>isarV0){
   //Alert(Ask+" "+isarV0);
       res=AdvOrderSend(Symbol(),OP_BUY,LotsOptimized(),Ask,3,isarV0-1*Point,Ask+TrailingStop*Point,"",MAGICMA,0,Blue);
        // OrderModify(res,Ask,isarV0-10*Point,Ask+TrailingStop*Point,0,CLR_NONE);
        ///Print("res="+res);
        
       return;
     }
   if(Ask<isarV0){
   // Alert(Ask+" "+isarV0);
       res=AdvOrderSend(Symbol(),OP_SELL,LotsOptimized(),Bid,3,isarV0+4*Point,Bid-TrailingStop*Point,"",MAGICMA,0,Red);
       //OrderModify(res,Bid,isarV0+40*Point,Bid-TrailingStop*Point,0,CLR_NONE);
        //Print("res="+res);
        
       return;
    }
    

//----
  }
//+------------------------------------------------------------------+
//| Check for close order conditions                                 |
//+------------------------------------------------------------------+
void CheckForClose()
  {

   int res;
//---- go trading only for first tiks of new bar

 if(Volume[0] < 4) return;
if(Volume[0] > 20) return;

 double isarV0 =  iSAR(NULL,0,step,maximum,0);
 
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)        break;
      if(OrderMagicNumber()!=MAGICMA || OrderSymbol()!=Symbol()) continue;
      //---- check order type 
      
      if(OrderType()==OP_BUY)
        {
         OrderModify(OrderTicket(),OrderOpenPrice(),isarV0-1*Point,Ask+TrailingStop*Point,0,CLR_NONE);
           if(Ask<isarV0){
            OrderClose(OrderTicket(),OrderLots(),Bid,30,White); 
           }
        }
      if(OrderType()==OP_SELL)
        { 
          OrderModify(OrderTicket(),OrderOpenPrice(),isarV0+4*Point,Ask-TrailingStop*Point,0,CLR_NONE);
          if(Ask>isarV0){
            OrderClose(OrderTicket(),OrderLots(),Ask,30,White); 
          }
         //OrderModify(OrderTicket(),OrderOpenPrice(),isarV0+3*Point,Ask-TrailingStop*Point,0,CLR_NONE);
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
//---- calculate open orders by current symbol //stemp 2128 2228
//if(Volume[0]>10) return;

   if(CalculateCurrentOrders(Symbol(),MAGICMA)==0) {
      //Print(Hour()*100+Minute()+">="+StartTime1);
       //Print(Hour()*100+Minute()+"<="+EndTime1);
      /*
      if(Hour()*100+Minute()>=StartTime1&&Hour()*100+Minute()<=EndTime1){
      
         CheckForOpen();
      }else
      if(Hour()*100+Minute()>=StartTime2&&Hour()*100+Minute()<=EndTime2){
         CheckForOpen();
      }else
      if(Hour()*100+Minute()>=StartTime3&&Hour()*100+Minute()<=EndTime3){
         CheckForOpen();
      }*/
      
      if(Hour()>=startHourTime){
       CheckForOpen();
      }
   }else{
   CheckForClose();
   }
//----
  }
//+------------------------------------------------------------------+  