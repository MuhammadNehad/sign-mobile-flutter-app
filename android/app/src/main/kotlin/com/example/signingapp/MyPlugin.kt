package com.example.signingapp

import android.app.Activity
import android.content.Intent
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MyPlugin : ActivityAware, FlutterPlugin,MethodChannel.MethodCallHandler {
    private  var mCallbackDispatcherHandle:Long = 0;
    private var activity: Activity? = null
    private var channel:MethodChannel?= null
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {


    }

    override fun onDetachedFromActivity() {

    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity= binding.activity;

    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
            activity= binding.activity;
    }

    override fun onDetachedFromActivityForConfigChanges() {

    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {


    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {

    }
}