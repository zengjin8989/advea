//+------------------------------------------------------------------+
//|                              ADV_iSAR_v103.mq4 |
//|                                                         zeng jin |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "zeng jin"

#include <advlib.mqh>
 
#define MAGICMA  52018031

extern double Lots = 10;
extern double step=0.02;
extern double maximum=0.2;

extern double TrailingStop = 100000;
extern double StopLoss =     100000;

extern int startHourTime=15;

extern int endHourTime=21;

extern bool DoesOverweight=false; //是否加码

extern double profit =0;
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
   Print(Ask+" "+isarV0+" NormalizeDouble(isarV0+400*Point,2)="+NormalizeDouble(isarV0+400*Point,2));
     //  res=AdvOrderSend(Symbol(),OP_BUY,LotsOptimized(),Ask,3,isarV0-1*Point,Ask+TrailingStop*Point,"",MAGICMA,0,Blue);
     res=AdvOrderSend(Symbol(),OP_SELLSTOP,LotsOptimized(),NormalizeDouble(isarV0-100*Point,2),30,0,0,"",MAGICMA,0,Blue);
        // OrderModify(res,Ask,isarV0-10*Point,Ask+TrailingStop*Point,0,CLR_NONE);
        ///Print("res="+res);
        
       return;
     }
   if(Ask<isarV0){
  Print(Ask+" "+isarV0+" NormalizeDouble(isarV0+400*Point,2)="+NormalizeDouble(isarV0+400*Point,2));
       res=AdvOrderSend(Symbol(),OP_BUYSTOP,LotsOptimized(),NormalizeDouble(isarV0+400*Point,2),30,0,0,"",MAGICMA,0,Red);
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

// if(Volume[0] < 4) return;
if(Volume[0] < 10) return;

 double isarV0 =  iSAR(NULL,0,step,maximum,0);
 // Print("CheckForClose isarV0="+isarV0); 
   for(int i=0;i<OrdersTotal();i++)
     {
     
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)        break;
     // Print("OrderMagicNumber()()="+OrderMagicNumber()+"  MAGICMA="+MAGICMA); 
      if(OrderMagicNumber()!=MAGICMA || OrderSymbol()!=Symbol()) continue;
      //---- check order type 
    //  Print("OrderType()="+OrderType()); 
      if(OrderType()==OP_BUY)
        {
         bool res2a4=OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(isarV0-100*Point,2),NormalizeDouble(isarV0,2)+TrailingStop*Point,0,CLR_NONE);
          if(!res2a4) 
               Print("Error in OrderModify. Error code=",GetLastError()+" isarV0="+NormalizeDouble(isarV0-100*Point,2)+" Ask+TrailingStop*Point="+(Ask+TrailingStop*Point)+" OrderOpenPrice()="+OrderOpenPrice()+" OrderTicket="+OrderTicket()); 
            else 
               Print("Order modified successfully."); 
          // if(Ask<isarV0){
          //  OrderClose(OrderTicket(),OrderLots(),Bid,30,White); 
          // }
        }
      if(OrderType()==OP_SELL)
        { 
           bool res2a3=OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(isarV0+400*Point,2),NormalizeDouble(isarV0,2)-TrailingStop*Point,0,CLR_NONE);
           if(!res2a3) 
               Print("Error in OrderModify. Error code=",GetLastError()+" isarV0="+NormalizeDouble(isarV0+400*Point,2)+" Ask+TrailingStop*Point="+(Ask-TrailingStop*Point)+" OrderOpenPrice()="+OrderOpenPrice()+" OrderTicket="+OrderTicket()); 
            else 
               Print("Order modified successfully."); 
         // if(Ask>isarV0){
          //  OrderClose(OrderTicket(),OrderLots(),Ask,30,White); 
         // }
         //OrderModify(OrderTicket(),OrderOpenPrice(),isarV0+3*Point,Ask-TrailingStop*Point,0,CLR_NONE);
        }
        if(OrderType()==OP_SELLSTOP)
        { 
          bool res2a2=OrderModify(OrderTicket(),NormalizeDouble(isarV0-100*Point,2),NormalizeDouble(isarV0,2)+StopLoss*Point,NormalizeDouble(isarV0,2)-TrailingStop*Point,0,CLR_NONE);
          if(!res2a2) 
               Print("Error in OrderModify. Error code=",GetLastError()+" isarV0"+NormalizeDouble(isarV0-100*Point,2)+" OrderTicket()="+OrderTicket()); 
            else 
               Print("Order modified successfully."); 
           

         // if(Ask>isarV0){
          //  OrderClose(OrderTicket(),OrderLots(),Ask,30,White); 
         // }
         //OrderModify(OrderTicket(),OrderOpenPrice(),isarV0+3*Point,Ask-TrailingStop*Point,0,CLR_NONE);
        }
        if(OrderType()==OP_BUYSTOP)
        { 
           bool res2a=OrderModify(OrderTicket(),NormalizeDouble(isarV0+400*Point,2),NormalizeDouble(isarV0,2)-StopLoss*Point,NormalizeDouble(isarV0,2)+TrailingStop*Point,0,CLR_NONE);
            if(!res2a) 
               Print("Error in OrderModify. Error code=",GetLastError()+" isarV0"+NormalizeDouble(isarV0-100*Point,2)+" OrderTicket()="+OrderTicket()); 
            else 
               Print("Order modified successfully."); 
           
         // if(Ask>isarV0){
          //  OrderClose(OrderTicket(),OrderLots(),Ask,30,White); 
         // }
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
if(Volume[0]>800&&Volume[0]<803){}
else
if(Volume[0]>600&&Volume[0]<603){}
else if(Volume[0]>400&&Volume[0]<403){}
else if(Volume[0]>200&&Volume[0]<203){}
else if(Volume[0]>90&&Volume[0]<93){}
else if(Volume[0]>50&&Volume[0]<53){}
else if(Volume[0]>20&&Volume[0]<33){}
else if(Volume[0]>10)
{ return; }

   if(CalculateCurrentSTOPOrders(Symbol(),MAGICMA)==0) {
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
      int sht = startHourTime;
      int eht = endHourTime;
      if(Month()>=3)
      {
         sht = startHourTime+1;
         eht = endHourTime+1;
         Print("Month()="+Month()+"  Day()="+Day() +" sht="+sht+" eht="+eht);
      }
     
      if(Hour()>=sht && Hour()<=eht ){
       CheckForOpen();
      }else{
       CheckForClose();
      }
      
   }else{
   CheckForClose();
   }
//----
  }
//+------------------------------------------------------------------+  