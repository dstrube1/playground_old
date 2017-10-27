/*
* Copyright (c) 1994-1998 Sun Microsystems, Inc. All Rights Reserved.
*
* Permission to use, copy, modify, and distribute this software and its
* documentation for NON-COMMERCIAL or COMMERCIAL purposes and without fee is
* hereby granted. Please refer to the file
* http://java.sun.com/nav/business/trademark_guidelines.html for further
* important copyright and trademark information and to
* http://java.sun.com/nav/business/index.html for further important licensing
* information for the Java (tm) Technology.
* 
* SUN MAKES NO REPRESENTATIONS OR WARRANTIES ABOUT THE SUITABILITY OF THE
* SOFTWARE, EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
* IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR
* NON-INFRINGEMENT. SUN SHALL NOT BE LIABLE FOR ANY DAMAGES SUFFERED BY
* LICENSEE AS A RESULT OF USING, MODIFYING OR DISTRIBUTING THIS SOFTWARE OR
* ITS DERIVATIVES.
* 
* THIS SOFTWARE IS NOT DESIGNED OR INTENDED FOR USE OR RESALE AS ON-LINE
* CONTROL EQUIPMENT IN HAZARDOUS ENVIRONMENTS REQUIRING FAIL-SAFE PERFORMANCE,
* SUCH AS IN THE OPERATION OF NUCLEAR FACILITIES, AIRCRAFT NAVIGATION OR
* COMMUNICATION SYSTEMS, AIR TRAFFIC CONTROL, DIRECT LIFE SUPPORT MACHINES, OR
* WEAPONS SYSTEMS, IN WHICH THE FAILURE OF THE SOFTWARE COULD LEAD DIRECTLY TO
* DEATH, PERSONAL INJURY, OR SEVERE PHYSICAL OR ENVIRONMENTAL DAMAGE ("HIGH
* RISK ACTIVITIES"). SUN SPECIFICALLY DISCLAIMS ANY EXPRESS OR IMPLIED
* WARRANTY OF FITNESS FOR HIGH RISK ACTIVITIES.
*/

   import java.applet.*;
   import java.awt.*;
   import java.net.*;
   import java.util.*;

   public class JavaClock2 extends Applet implements Runnable
   {
      private ParamParser param;
      private Dimension size;
      private Image offImage;
      private Graphics offG;
      private Thread animate;
   
      private long delay;
      private Font cfont;
      private FontMetrics cfm;
   
      private Rectangle arect;
      private int border;
   
      private AnalogClock aclock;
   
      public void init()
      {
         size = size();
         param = new ParamParser(this);
      
         delay = 500;//param.parseInt("delay", 100);
      
      // Create the offImage for double-buffering.
      
         //offImage = createImage(size.width, size.height);
         offG = offImage.getGraphics();
      
         //offG.fillRect(0, 0, size.width, size.height);
      
         border = param.parseInt("border", 10);
      
         arect = new Rectangle(border, border, size.width - (2 * border),
                              size.height - (2 * border));
         //cfont = param.parseFont("cfont", "TimesRoman", Font.PLAIN, 10);
      
         //offG.setFont(cfont);
         cfm = offG.getFontMetrics();
      
         aclock = new AnalogClock(arect, param, cfm);
      }
   
      public void start()
      {
         if ((animate == null) || (!animate.isAlive()))
         {
            animate = new Thread(this);
         }
      
         animate.start();
      }
   
      public void run()
      {
         while (Thread.currentThread() == animate)
         {
            try
            {
               repaint();
               //System.out.println(aclock.timeToString());
               Thread.sleep(delay);
            }
            
               catch (InterruptedException e)
               {
                  e.printStackTrace();
               }
         }
      }
   

      public void update(Graphics g)
      {
         aclock.draw(offG);
         paint(g);
      }
   
      public void paint(Graphics g)
      {
         g.drawImage(offImage, 0, 0, this);
      }
   
   
   
   }
