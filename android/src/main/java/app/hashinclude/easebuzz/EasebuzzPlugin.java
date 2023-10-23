package app.hashinclude.easebuzz;

import android.content.Context;
import android.content.Intent;

import androidx.activity.result.ActivityResult;
import androidx.activity.result.ActivityResultCallback;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;

import com.easebuzz.payment.kit.PWECouponsActivity;
import com.google.gson.Gson;

import org.json.JSONObject;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

import datamodels.PWEStaticDataModel;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/** EasebuzzPlugin */
public class EasebuzzPlugin extends AppCompatActivity implements FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;

  private static final String CHANNEL = "easebuzz";
  MethodChannel.Result channel_result;
  private boolean start_payment = true;
  private Context context;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "easebuzz");
    context = flutterPluginBinding.getApplicationContext();

    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    channel_result  = result;
    if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
      return;

    }

    if(call.method.equals("openPaymentGateway")){

      start_payment = true;

      if(start_payment){
        start_payment = false;
        startPayment(call.arguments);
      }

    }
      result.notImplemented();

  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

  private  void startPayment(Object arguments){
    try {
      Gson gson = new Gson();
      JSONObject parameters = new JSONObject(gson.toJson(arguments));
      Intent intentProceed = new Intent(context, PWECouponsActivity.class);

      intentProceed.setFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT);
      setResult(PWEStaticDataModel.PWE_REQUEST_CODE);
      Iterator<?> keys = parameters.keys();
      while(keys.hasNext() ) {
        String value = "";
        String key = (String) keys.next();
        value = parameters.optString(key);
        if (key.equals("amount")){
          Double amount = new Double(parameters.optString("amount"));
          intentProceed.putExtra(key,amount);
        } else {
          intentProceed.putExtra(key,value);
        }
      }
      registerForActivityResult(new ActivityResultContracts.StartActivityForResult(), new ActivityResultCallback<ActivityResult>() {
        @Override
        public void onActivityResult(ActivityResult result) {
          if(result.getResultCode() == PWEStaticDataModel.PWE_REQUEST_CODE){
              if(result.getData()!=null){
                initiatePayment(result.getData());
              }
          }
        }
      });
    }catch (Exception e) {
      start_payment=true;
      Map<String, Object> error_map = new HashMap<>();
      Map<String, Object> error_desc_map = new HashMap<>();
      String error_desc = "exception occured:"+e.getMessage();
      error_desc_map.put("error","Exception");
      error_desc_map.put("error_msg",error_desc);
      error_map.put("result",PWEStaticDataModel.TXN_FAILED_CODE);
      error_map.put("payment_response",error_desc_map);
      channel_result.success(error_map);
    }
  }

 private  void initiatePayment(Intent data){

         start_payment = true;
         JSONObject response = new JSONObject();
         Map<String, Object> error_map = new HashMap<>();
         if (data != null) {
           String result = data.getStringExtra("result");
           String payment_response = data.getStringExtra("payment_response");
           try {
             JSONObject obj = new JSONObject(payment_response);
             response.put("result", result);
             response.put("payment_response", obj);
             channel_result.success(JsonConverter.convertToMap(response));
           } catch (Exception e) {
             Map<String, Object> error_desc_map = new HashMap<>();
             error_desc_map.put("error", result);
             error_desc_map.put("error_msg", payment_response);
             error_map.put("result", result);
             error_map.put("payment_response", error_desc_map);
             channel_result.success(error_map);
           }
         } else {
           Map<String, Object> error_desc_map = new HashMap<>();
           String error_desc = "Empty payment response";
           error_desc_map.put("error", "Empty error");
           error_desc_map.put("error_msg", error_desc);
           error_map.put("result", "payment_failed");
           error_map.put("payment_response", error_desc_map);
           channel_result.success(error_map);
         }



 }
}
