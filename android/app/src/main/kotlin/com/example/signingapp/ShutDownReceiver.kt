package com.example.signingapp

import android.annotation.SuppressLint
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.os.Build
import android.util.Log
import android.widget.Toast

import java.time.OffsetDateTime
import java.time.ZoneId
import java.time.ZoneOffset
import java.time.ZonedDateTime
import java.time.format.DateTimeFormatter


class ShutDownReceiver : BroadcastReceiver() {
    @SuppressLint("SimpleDateFormat", "NewApi")
    override fun onReceive(context: Context?, intent: Intent?) {
        val sharedPreferences: SharedPreferences = context!!.getSharedPreferences("FlutterSharedPreferences",Context.MODE_PRIVATE)
        if(intent?.action == Intent.ACTION_SHUTDOWN ||intent?.action == Intent.ACTION_REBOOT )
        {
            Log.d("ShutD","Shutting")
            Toast.makeText(context,"Shutting Down",Toast.LENGTH_SHORT).show()
            val editor:SharedPreferences.Editor = sharedPreferences.edit()
            editor.putBoolean("flutter.ShutDown", true);
            val offsetdatetime = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                OffsetDateTime.now(ZoneOffset.UTC).plusHours(2)
            } else {

                ZonedDateTime.now(ZoneId.of("Etc/UTC")).plusHours(2) };
            val sdf = DateTimeFormatter.ofPattern("yyyy-MM-dd hh:mm:ss")
            editor.putString("flutter.shutdownTime", sdf.format(offsetdatetime));

            editor.apply()
            val sharedPreferencesNative: SharedPreferences = context!!.getSharedPreferences("EmpServiceSharedPrefFile",Context.MODE_PRIVATE)
            EmpService.closingService(sharedPreferencesNative)

        }else if(intent?.action == "android.intent.action.BOOT_COMPLETED" || intent?.action == "android.intent.action.LOCKED_BOOT_COMPLETED"){
            Toast.makeText(context, "Booted", Toast.LENGTH_SHORT).show()

            val myCOde:String? = sharedPreferences.getString("flutter.myCode",null);
            if(!myCOde.isNullOrEmpty()) {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    context?.startForegroundService(Intent(context, EmpService::class.java))
                } else {
                    context?.startService(Intent(context, EmpService::class.java))
                }
            }
        }
    }
}