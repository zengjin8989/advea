//+------------------------------------------------------------------+
//|                                                    iSAR_v001.mq4 |
//|                                                         zeng jin |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "zeng jin"
#define MAGICMA  20090310

extern double Lots               = 0.1;
extern double MaximumRisk        = 0.02;
extern double DecreaseFactor     = 3;
extern double MovingPeriod       = 13;
extern double MovingPeriod2       = 21;
extern double MovingShift        = 0;
extern double step=0.02;
extern double maximum=0.3;

extern double profit             =0;
extern int    MaxSafety =10000;    //保险指数
extern int    per = 14;
extern double TrailingStop = 5000;
extern double StopLoss = 5000;
int type=OP_BUY;
   double openv,closev;
   int isClose=0;
extern int  IFShiftValue=40;
extern int  ShiftValue=0;
extern int  Sindex=0;
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
   if((AccountBalance()/MaxSafety)>1)
   {
 //c=NormalizeDouble((AccountBalance()/MaxSafety),1);
  }
   lot=0.1;
  if(profit<-180){
   //lot=lot+0.9;
   }
 //  if(profit<-1000*c){
 //  lot=lot+1;
 //  }
   
  
   

  /* if(AccountBalance()>800){
   lot = lot*NormalizeDouble((AccountBalance()/800),0);
   }else{
   }*/
   //Print("NormalizeDouble((AccountBalance()/500),1)=======================================",NormalizeDouble((AccountBalance()/500),1));
 
 // if(lot>0.1)
//  {
 // lot = lot+(c-1);
//  }
  //lot=0.1;
   return(lot);
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
   
//---- get Moving Average 
 double isarV0 =  iSAR(NULL,0,step,maximum,0);
   double isarV1 =  iSAR(NULL,0,step,maximum,1);
  /*
   Print("CheckForOpen()+++");
   if(isClose==0){
      if(Ask>isarV0){
         type=OP_BUY;
         openv=Ask;
          isClose=1;
      }
      if(Ask<isarV0){
         type=OP_SELL;
         openv=Ask;
           isClose=1;
      }
   }else{
      if(type==OP_BUY&&Ask<isarV0){
         closev=Ask;
         ShiftValue = (closev-openv)/Point;
         if(ShiftValue<3){
         Sindex++;
         }else{
         Sindex=0;
         }
         isClose=0;
      }
      if(type==OP_SELL&&Ask>isarV0){
         closev=Ask;
         ShiftValue = (openv-closev)/Point;
         if(ShiftValue<3){
         Sindex++;
         }else{
         Sindex=0;
         }
         isClose=0;
      }
   }
   if(Sindex<11)
   {
      return;
   }
   */
   //Sindex=0;
   if(Ask>isarV0){
       res=OrderSend(Symbol(),OP_BUY,LotsOptimized(),Ask,30,isarV0-30*Point,Ask+TrailingStop*Point,"",MAGICMA,0,Blue);
         return;
     }
   if(Ask<isarV0){
        res=OrderSend(Symbol(),OP_SELL,LotsOptimized(),Bid,30,isarV0+30*Point,Bid-TrailingStop*Point,"",MAGICMA,0,Red);
         return;
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
        double MacdCurrent, MacdPrevious, SignalCurrent;
double SignalPrevious, MaCurrent, MaPrevious;
   int res;
//---- go trading only for first tiks of new bar
 

 double isarV0 =  iSAR(NULL,0,step,maximum,0);
 
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)        break;
      if(OrderMagicNumber()!=MAGICMA || OrderSymbol()!=Symbol()) continue;
      //---- check order type 
      if(OrderType()==OP_BUY)
        {
         //OrderModify(OrderTicket(),OrderOpenPrice(),isarV0-3*Point,Ask+TrailingStop*Point,0,CLR_NONE);
           if(Ask<isarV0){
             if(Bid-OrderOpenPrice()>100*Point){
                Sindex=0;
             }
             OrderClose(OrderTicket(),OrderLots(),Bid,30,White); 
             
           }
        }
      if(OrderType()==OP_SELL)
        { 
          if(Ask>isarV0){
            if(OrderOpenPrice()-Ask>100*Point)
            {
               Sindex=0;
            }
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
//---- calculate open orders by current symbol
//if(Volume[0]>20) return;
   if(CalculateCurrentOrders(Symbol())==0) {
    if(Hour()<9||Hour()>19){   //北京时间Hour()<03&&Hour()12  if(Hour()<15&&Hour()>0){
      return;
   }
   CheckForOpen();
   }else{
   CheckForClose();
   }
//----
  }
//+------------------------------------------------------------------+  
  
//+------------------------------------------------------------------+