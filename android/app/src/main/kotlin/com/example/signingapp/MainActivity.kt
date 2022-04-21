package com.example.signingapp


import android.app.ActivityManager
import android.app.AlertDialog
import android.content.*
import android.content.pm.PackageManager
import android.net.ConnectivityManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import android.util.Log
import android.widget.Toast
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel


class MainActivity: FlutterActivity()  {
    companion object{
        var flutterEngineInstance: FlutterEngine? = null
    }
    private  var mCallbackDispatcherHandle:Long = 0;

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val br: BroadcastReceiver = ShutDownReceiver();
        try{
            this.unregisterReceiver(br);
        }catch(ex:IllegalArgumentException)
        {
            ex.printStackTrace()
        }
        val intentfilter:IntentFilter= IntentFilter(ConnectivityManager.CONNECTIVITY_ACTION)
        intentfilter.addAction(Intent.ACTION_POWER_DISCONNECTED)
        intentfilter.addAction(Intent.ACTION_POWER_CONNECTED)
        intentfilter.addAction(Intent.ACTION_SHUTDOWN)
        intentfilter.addAction(Intent.ACTION_BOOT_COMPLETED)
        intentfilter.addAction(Intent.ACTION_REBOOT)
        this.registerReceiver(br,intentfilter)
//        Toast.makeText(this.getApplicationContext(),"foundWay", Toast.LENGTH_SHORT).show()
        MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger,
                "main_channel").setMethodCallHandler { call, result ->
            val sharedPreferences: SharedPreferences = this.getSharedPreferences("EmpServiceSharedPrefFile",Context.MODE_PRIVATE)
            val editor:SharedPreferences.Editor = sharedPreferences.edit()
            val args:ArrayList<*> = call.arguments();
            val callbackhandler =args.get(0) as Long;


            mCallbackDispatcherHandle =callbackhandler
            if(mCallbackDispatcherHandle!=null && mCallbackDispatcherHandle!=0L) {
                editor.putLong("CallbackDispatcherHandleKEY", mCallbackDispatcherHandle);
                editor.putLong("CALLBACKHANDLEKEY", callbackhandler);

                editor.apply()
            }
            if(call.method.equals("initializeService"))
            {

            if(!isMyServiceRunnign(EmpService::class.java)) {
                val i: Intent = Intent(this, EmpService::class.java)
                i.putExtra("CALLBACKHANDLEKEY", callbackhandler)
                i.putExtra("CALLBACKDISPATCHERHANDLEKEY", sharedPreferences.getLong("CallbackDispatcherHandleKEY", 0))
                activity.startService(i)
            }
                result.success(null);

            }else if(call.method.equals("run")) {

            }else {
                result.notImplemented()
            }
        }

        MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger,
                "permissions").setMethodCallHandler { call, result ->
            }
        }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
    if(resultCode ==2)
    {

    }
    }
    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        when(requestCode)
        {
            2->{
                if((grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED))
                {
                    Toast.makeText(this,"Permission is granted",Toast.LENGTH_SHORT).show();
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        shouldShowRequestPermissionRationale("We need to access background location to continue recording your efforts during working hours.")
                    };
                }else{
                    Toast.makeText(this,"Permission is denied ",Toast.LENGTH_SHORT).show();

                }
                return
            }        else -> {

            }
        }
    }
    private fun isMyServiceRunnign( serviceClass:Class<*>):Boolean
    {
        var manage:ActivityManager =getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        for (service:ActivityManager.RunningServiceInfo in manage.getRunningServices(Integer.MAX_VALUE))
        {
            if(serviceClass.name.equals(service.service.className))
            {
                Log.i("Service Status","Running")
                stopService(Intent(this, Class.forName( service.service.className)))
                var intent:Intent = Intent();
                intent.setAction("restartservice");
                intent.setClass(this,EmpBroadCast::class.java)
                this.sendBroadcast(intent)

                return true
            }
        }
        return false
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
//        flutterEngineInstance= flutterEngine
//
//        if(!isMyServiceRunnign(EmpService::class.java)) {
//            Intent(this, EmpService::class.java).also { intent ->
//                startService(intent)
//            }
//        }
    }

    // override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    //     val args:ArrayList<*> = call.arguments();
    //     val callbackhandler =args.get(0) as Long;
    //     if(call.method.equals("initializeService"))
    //     {
    //         mCallbackDispatcherHandle = callbackhandler;
    //         result.success(null);
    //         return;
    //     }else if(call.method.equals("run")){
    //         val i:Intent= Intent(this,EmpService::class.java)
    //         i.putExtra("CALLBACKHANDLEKEY",callbackhandler)
    //         i.putExtra("CALLBACKDISPATCHERHANDLEKEY",mCallbackDispatcherHandle)
    //         activity?.startService(i)
    //         result.success(null)
    //         return;
    //     }

    // }

}
