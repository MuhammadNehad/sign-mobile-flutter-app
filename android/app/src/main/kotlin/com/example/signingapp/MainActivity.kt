package com.example.signingapp

import android.app.ActivityManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.os.Bundle
import android.os.Debug
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel


class MainActivity: FlutterActivity() , MethodChannel.MethodCallHandler {
    companion object{
        var flutterEngineInstance: FlutterEngine? = null
    }
    private  var mCallbackDispatcherHandle:Long = 0;

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
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


    }
    private fun isMyServiceRunnign( serviceClass:Class<*>):Boolean
    {
        var manage:ActivityManager =getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        for (service:ActivityManager.RunningServiceInfo in manage.getRunningServices(Integer.MAX_VALUE))
        {
            if(serviceClass.name.equals(service.service.className))
            {
//                Log.i("Service Status","Running")
//                stopService(Intent(this, Class.forName( service.service.className)))
//                var intent:Intent = Intent();
//                intent.setAction("restartservice");
//                intent.setClass(this,EmpBroadCast::class.java)
//                this.sendBroadcast(intent)

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

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val args:ArrayList<*> = call.arguments();
        val callbackhandler =args.get(0) as Long;
        if(call.method.equals("initializeService"))
        {
            mCallbackDispatcherHandle = callbackhandler;
            result.success(null);
            return;
        }else if(call.method.equals("run")){
            val i:Intent= Intent(this,EmpService::class.java)
            i.putExtra("CALLBACKHANDLEKEY",callbackhandler)
            i.putExtra("CALLBACKDISPATCHERHANDLEKEY",mCallbackDispatcherHandle)
            activity?.startService(i)
            result.success(null)
            return;
        }

    }

}
