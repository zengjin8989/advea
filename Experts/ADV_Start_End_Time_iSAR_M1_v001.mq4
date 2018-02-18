//+------------------------------------------------------------------+
//|                              ADV_Start_End_Time_iSAR_M1_v001.mq4 |
//|                                                         zeng jin |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "zeng jin"
#define MAGICMA  20090605

extern double Lots               = 0.1;
extern double step=0.02;
extern double maximum=0.2;
extern int StartTime=100000;
extern int EndTime=100000;
extern double TrailingStop = 5000;
extern double StopLoss = 5000;
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
  // double isarV1 =  iSAR(NULL,0,step,maximum,1);
 Print(isarV0);
   //Sindex=0;
   if(Ask>isarV0){
       res=OrderSend(Symbol(),OP_BUY,LotsOptimized(),Ask,30,0,0,"",MAGICMA,0,Blue);
         OrderModify(res,Ask,isarV0-10*Point,Ask+TrailingStop*Point,0,CLR_NONE);
       return;
     }
   if(Ask<isarV0){
       res=OrderSend(Symbol(),OP_SELL,LotsOptimized(),Bid,30,0,0,"",MAGICMA,0,Red);
       OrderModify(res,Bid,isarV0+40*Point,Bid-TrailingStop*Point,0,CLR_NONE);
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
 if(Volume[0]>6) return;

 double isarV0 =  iSAR(NULL,0,step,maximum,0);
 
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)        break;
      if(OrderMagicNumber()!=MAGICMA || OrderSymbol()!=Symbol()) continue;
      //---- check order type 
      
      if(OrderType()==OP_BUY)
        {
         OrderModify(OrderTicket(),OrderOpenPrice(),isarV0-10*Point,Ask+TrailingStop*Point,0,CLR_NONE);
           //if(Ask<isarV0){
            // OrderClose(OrderTicket(),OrderLots(),Bid,30,White); 
             
          // }
        }
      if(OrderType()==OP_SELL)
        { 
          OrderModify(OrderTicket(),OrderOpenPrice(),isarV0+40*Point,Ask-TrailingStop*Point,0,CLR_NONE);
          //if(Ask>isarV0){
            //OrderClose(OrderTicket(),OrderLots(),Ask,30,White); 
          //}
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
//---- calculate open orders by current symbol
//if(Volume[0]>10) return;
   if(CalculateCurrentOrders(Symbol())==0) {
    if(Hour()*100+Minute()>=StartTime&&Hour()*100+Minute()<=EndTime){
      CheckForOpen();
   }
   }else{
   CheckForClose();
   }
//----
  }
//+------------------------------------------------------------------+  