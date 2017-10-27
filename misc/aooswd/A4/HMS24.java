//David Strube
//CSIS4650
//Assignment 4
//Observer Pattern

  
	import java.util.*; 

   public class HMS24{
      private Calendar time_main;
      public HMS24(){
         time_main=new GregorianCalendar();
         print();
      }
   
      public void print(){
         time_main=new GregorianCalendar();
         System.out.print("HMS24 says Time is "+time_main.get(Calendar.HOUR_OF_DAY));
         if (time_main.get(Calendar.MINUTE)<10)
            System.out.print(":0"+time_main.get(Calendar.MINUTE));
         else
            System.out.print(":"+time_main.get(Calendar.MINUTE));
         if (time_main.get(Calendar.SECOND)<10)
            System.out.println(":0"+time_main.get(Calendar.SECOND));
         else
            System.out.println(":"+time_main.get(Calendar.SECOND));
      }
   
   }