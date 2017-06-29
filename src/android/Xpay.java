package cordova.plugin;

import android.util.Log;

import org.apache.cordova.CordovaArgs;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PluginResult;
import org.apache.cordova.CallbackContext;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

// wechat sdk
import com.tencent.mm.opensdk.modelpay.PayReq;
import com.tencent.mm.opensdk.openapi.IWXAPI;
import com.tencent.mm.opensdk.openapi.WXAPIFactory;

/**
 * This class echoes a string called from JavaScript.
 */
public class Xpay extends CordovaPlugin {
    public static final String TAG = "Cordova.Pligun.Xpay";
    public static IWXAPI wxAPI;
    public static CallbackContext currentCallbackContext;

    protected boolean wxPayment(CordovaArgs args, CallbackContext callbackContext) {
        final JSONObject params;
        try {
            params = args.getJSONObject(0);
        } catch (JSONException E) {
          callbackContext.error("参数格式错误");
          return true;
        }

        PayReq req = new PayReq();

        String appId;
        try {
            appId = params.getString("appId");
            req.partnerId = params.getString("partnerId");
            req.prepayId = params.getString("prepayId");
            req.nonceStr = params.getString("nonceStr");
            req.timeStamp = params.getString("timeStamp");
            req.sign = params.getString("sign");
            req.packageValue = "Sign=WXPay";
        } catch (Exception e) {
            Log.e(TAG, e.getMessage());
            callbackContext.error("参数格式错误");
            return true;
        }

        wxAPI = WXAPIFactory.createWXAPI(webView.getContext(), appId, true);
        wxAPI.registerApp(appId);

        if (wxAPI.sendReq(req)) {
            Log.i(TAG, "Payment request has been sent successfully.");

            // send no result
            sendNoResultPluginResult(callbackContext);
        } else {
            Log.i(TAG, "Payment request has been sent unsuccessfully.");

            // send error
            callbackContext.error("Payment request has been sent unsuccessfully.");
        }

        return true;
    }


    @Override
    public boolean execute(String action, CordovaArgs args, CallbackContext callbackContext) throws JSONException {
        if (action.equals("wxPayment")) {
            wxPayment(args, callbackContext);
            return true;
        }
        return false;
    }

    private void sendNoResultPluginResult(CallbackContext callbackContext) {
        currentCallbackContext = callbackContext;

        PluginResult result = new PluginResult(PluginResult.Status.NO_RESULT);
        result.setKeepCallback(true);
        callbackContext.sendPluginResult(result);
    }
}
