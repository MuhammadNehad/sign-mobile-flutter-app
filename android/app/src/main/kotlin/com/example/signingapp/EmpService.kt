package com.example.signingapp

import android.Manifest
import android.accessibilityservice.GestureDescription
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.*
import android.content.pm.PackageManager
import android.content.res.Configuration
import android.graphics.Color
import android.os.*
import android.util.Log
import android.widget.Toast
import androidx.core.app.NotificationCompat
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.FileDescriptor
import java.io.PrintWriter
import android.location.Location
import android.net.ConnectivityManager
import androidx.core.app.ActivityCompat
import com.google.android.gms.location.*
import io.flutter.embedding.android.FlutterView
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodCall
import io.flutter.view.FlutterCallbackInformation
import io.flutter.view.FlutterMain
import io.flutter.view.FlutterNativeView
import io.flutter.view.FlutterRunArguments
import java.lang.Exception


class EmpService : Service() ,MethodChannel.MethodCallHandler{
    private lateinit var context: Context
    private lateinit var mBackgroundChannel2: MethodChannel
    private val TAG: String = "Emp Service"
    private var working: Boolean = false
    private var location:Location?= null
    private var locationRequest:LocationRequest?= null
    private var locationCallBack:LocationCallback?= null
    private var fuseLocationProvier:FusedLocationProviderClient?= null
    private var serviceLooper: Looper? = null
    private var serviceHandler: ServiceHandler? = null
    companion object ServiceHelpers{
        private var mtimer: Handler? = null
        fun closingService(sharedPreferences: SharedPreferences)
        {
            val editor:SharedPreferences.Editor = sharedPreferences.edit()
            editor.putBoolean("isServiceOn",false)
            editor.apply()
            if (mtimer != null) {
                mtimer?.removeCallbacksAndMessages(null)
                mtimer = null
            }

        }
    }
    // Handler that receives messages from the thread
    private inner class ServiceHandler(looper: Looper) : Handler(looper) {

        override fun handleMessage(msg: Message) {
            // Normally we would do some work here, like download a file.
            // For our sample, we just sleep for 5 seconds.
            try {
                Thread.sleep(5000)
            } catch (e: InterruptedException) {
                // Restore interrupt status.
                Thread.currentThread().interrupt()
            }

            // Stop the service using the startId, so that we don't stop
            // the service in the middle of handling another job
            stopSelf(msg.arg1)
        }
    }
    override fun onBind(intent: Intent?): IBinder? {
        TODO("Not yet implemented")
    }
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        restartReceiver()
        var sharedPreferences: SharedPreferences = this.getSharedPreferences("EmpServiceSharedPrefFile",Context.MODE_PRIVATE)
        try {

            context=this.applicationContext
            val cbdh:Long =sharedPreferences.getLong("CallbackDispatcherHandleKEY",0)
            var isWorking:Boolean =sharedPreferences.getBoolean("isServiceOn",false)
            val fnv:FlutterEngine = FlutterEngine(this)

            val fcbI:FlutterCallbackInformation = FlutterCallbackInformation.lookupCallbackInformation(cbdh)
            val fa:FlutterRunArguments = FlutterRunArguments();
            fa.bundlePath =FlutterMain.findAppBundlePath()

            val args = DartExecutor.DartCallback(
                    this.assets,
                    fa.bundlePath,
                    fcbI
            )
            Log.i(TAG, "service started ")

            fnv.getDartExecutor().executeDartCallback(args)
            // fuseLocationProvier=LocationServices.getFusedLocationProviderClient(this);
            // createLocationRequest();
            mBackgroundChannel2 = MethodChannel(fnv.dartExecutor.binaryMessenger ,
                    "empLocService.Service")

//        locationCallBack =object:LocationCallback()
//        {
//            override fun onLocationAvailability(p0: LocationAvailability?) {
//                super.onLocationAvailability(p0)
//            }
//
//            override fun onLocationResult(p0: LocationResult) {
//                super.onLocationResult(p0)
//
//
//
//
//            }
//        }

//        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED && ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_COARSE_LOCATION) == PackageManager.PERMISSION_GRANTED) {
//            // TODO: Consider calling
//            //    ActivityCompat#requestPermissions
//            // here to request the missing permissions, and then overriding
//            //   public void onRequestPermissionsResult(int requestCode, String[] permissions,
//            //                                          int[] grantResults)
//            // to handle the case where the user grants the permission. See the documentation
//            // for ActivityCompat#requestPermissions for more details.
////            fuseLocationProvier!!.requestLocationUpdates(locationRequest,locationCallBack, Looper.myLooper())
////            getlastloc()
//        }
//

            if(!isWorking || mtimer== null)
            {
                if (mtimer == null) {
                    mtimer = Handler(Looper.getMainLooper());
                }
                try {


                    mtimer?.post(object : Runnable {
                        override fun run() {
                            sharedPreferences = getSharedPreferences("EmpServiceSharedPrefFile",Context.MODE_PRIVATE)
                            val cbh:Long =sharedPreferences.getLong("CALLBACKHANDLEKEY",0)
                            val l:ArrayList<*> =  arrayListOf(
                                    cbh

                            );
                            val editor:SharedPreferences.Editor = sharedPreferences.edit()
                            editor.putBoolean("isServiceOn",true)
                            editor.apply()
                            working = true;
                            Log.i(TAG, "entered Here ")
                            mBackgroundChannel2.invokeMethod("saveLocations", l, object : MethodChannel.Result {
                                override fun notImplemented() {
                                    Log.i(TAG, "Not Implemented ")
                                }

                                override fun error(errorCode: String?, errorMessage: String?, errorDetails: Any?) {
                                    Log.i(TAG, "failed " + errorCode + ":" + errorMessage)
                                    sharedPreferences = getSharedPreferences("EmpServiceSharedPrefFile",Context.MODE_PRIVATE)
                                    val editor:SharedPreferences.Editor = sharedPreferences.edit()
                                    editor.putBoolean("isServiceOn",false)
                                    editor.apply()   }

                                override fun success(result: Any?) {
                                    Log.i(TAG, "succedded ")
                                }

                            })
                            mtimer?.postDelayed(this, 10000)
                        }

                    });
                }catch (ex:Exception)
                {
                    removeFlutterShared()
                    sharedPreferences = getSharedPreferences("EmpServiceSharedPrefFile",Context.MODE_PRIVATE)
                    val editor:SharedPreferences.Editor = sharedPreferences.edit()
                    editor.putBoolean("isServiceOn",false)
                    editor.apply()
                }
            }
        }catch ( ex:Exception)
        {
            removeFlutterShared()

            sharedPreferences = getSharedPreferences("EmpServiceSharedPrefFile",Context.MODE_PRIVATE)
            val editor:SharedPreferences.Editor = sharedPreferences.edit()
            editor.putBoolean("isServiceOn",false)
            editor.apply()

        }

        return START_STICKY
    }


    fun removeFlutterShared()
    {
        val fluttersharedPreferences: SharedPreferences = context!!.getSharedPreferences("FlutterSharedPreferences",Context.MODE_PRIVATE)
        if(fluttersharedPreferences.contains("flutter.started Process...."))
        {
            val fluttereditor:SharedPreferences.Editor = fluttersharedPreferences.edit()
            fluttereditor.remove("flutter.started Process....")
            fluttereditor.apply()
        }
    }
    fun createLocationRequest()
    {
        locationRequest = LocationRequest.create()
        locationRequest!!.interval = 10000
        locationRequest!!.fastestInterval = 10000
        locationRequest!!.priority = LocationRequest.PRIORITY_HIGH_ACCURACY
        locationRequest!!.smallestDisplacement =0.0.toFloat()
        

    }
    fun getlastloc()
    {
//        try {
//            fuseLocationProvier!!.lastLocation.addOnCompleteListener {task ->
//                if(task.isSuccessful && task.result!=null)
//                {
//                    location= task.result
//                }else{
//
//                }
//            }
//        }catch (unlikely:SecurityException)
//        {
//
//        }
    }
    fun empFun( context: Context) {
        Log.i(TAG, "entered emp Fun ")

    }

    override fun onConfigurationChanged(newConfig: Configuration) {
        super.onConfigurationChanged(newConfig)
    }

    override fun onRebind(intent: Intent?) {
        super.onRebind(intent)
    }

    override fun dump(fd: FileDescriptor?, writer: PrintWriter?, args: Array<out String>?) {
        super.dump(fd, writer, args)
    }

    fun restartReceiver()
    {
        val br: BroadcastReceiver = ShutDownReceiver();
        try{
            this.unregisterReceiver(br);
        }catch(ex:IllegalArgumentException)
        {
            ex.printStackTrace()
        }
        val intentfilter: IntentFilter = IntentFilter(ConnectivityManager.CONNECTIVITY_ACTION)
        intentfilter.addAction(Intent.ACTION_POWER_DISCONNECTED)
        intentfilter.addAction(Intent.ACTION_POWER_CONNECTED)
        intentfilter.addAction(Intent.ACTION_SHUTDOWN)
        intentfilter.addAction(Intent.ACTION_BOOT_COMPLETED)
        intentfilter.addAction(Intent.ACTION_REBOOT)
        this.registerReceiver(br,intentfilter)
    }
    override fun onCreate() {
        super.onCreate()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val NOTIFICATION_CHANNEL_ID = "example.permanence"
            val channelName = "Background Service"
            val chan = NotificationChannel(NOTIFICATION_CHANNEL_ID, channelName, NotificationManager.IMPORTANCE_NONE)
            chan.lightColor = Color.BLUE
            chan.lockscreenVisibility = Notification.VISIBILITY_PRIVATE

            val manager: NotificationManager = (getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager)!!
            manager.createNotificationChannel(chan)
            
            val notificationBuilder: NotificationCompat.Builder = NotificationCompat.Builder(this, NOTIFICATION_CHANNEL_ID)
            val notification: Notification = notificationBuilder.setOngoing(true)
                    .setContentTitle("App is running in background")
                    .setPriority(NotificationManager.IMPORTANCE_MAX)
                    .setCategory(Notification.CATEGORY_SERVICE)
                .setVibrate(null)
                    .build()
            startForeground(1, notification);
        }else{
            val notificationBuilder: NotificationCompat.Builder = NotificationCompat.Builder(this, "example.permanence")
            val notification: Notification = notificationBuilder.setOngoing(true)
                .setVibrate(null).setContentTitle("App is running in background")


                    .build()
            startForeground(1, notification)
        }


    }

    override fun onLowMemory() {
        super.onLowMemory()
    }


    override fun onTrimMemory(level: Int) {
        super.onTrimMemory(level)
    }

    override fun onUnbind(intent: Intent?): Boolean {
        return super.onUnbind(intent)
    }

    override fun attachBaseContext(newBase: Context?) {
        super.attachBaseContext(newBase)
    }


    override fun onDestroy() {
        super.onDestroy()
        restartReceiver()
        removeFlutterShared()
        val sharedPreferences: SharedPreferences = this.getSharedPreferences("EmpServiceSharedPrefFile",Context.MODE_PRIVATE)

        closingService(sharedPreferences)
        val intent:Intent = Intent();
         intent.setAction("restartservice");
         intent.setClass(this,EmpBroadCast::class.java)
         this.sendBroadcast(intent)

    }

    override fun onTaskRemoved(rootIntent: Intent?) {
        super.onTaskRemoved(rootIntent)
//         if(mtimer!=null)
//         {
//             working =false
// //            mtimer?.removeCallbacksAndMessages(null);
//         }
//         var intent:Intent = Intent();
//         intent.setAction("restartservice");
//         intent.setClass(this,EmpBroadCast::class.java)
//         this.sendBroadcast(intent)

    }


    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {

    }
}