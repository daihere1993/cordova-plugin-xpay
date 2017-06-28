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
import com.tencent.mm.sdk.modelpay.PayReq;
import com.tencent.mm.sdk.openapi.IWXAPI;
import com.tencent.mm.sdk.openapi.WXAPIFactory;

/**
 * This class echoes a string called from JavaScript.
 */
public class Xpay extends CordovaPlugin {
    public static final String TAG = "Cordova.Pligun.Xpay";
    protected CallbackContext currentCallbackContext;

    protected boolean wxPayment(CordovaArgs args, CallbackContext callbackContext) {
        final IWXAPI wxAPI;
        final JSONObject params;
        params = args.getJSONObject(0);

        final String[] paramKeys = new String[]{"partnerId", "prepayId", "timeStamp", "nonceStr", "sign"};

        PayReq req = new PayReq();

        // regster app
        String appId = params.getString("appId");
        wxAPI.registerApp(appId);

        for (int i = 0; i < paramKeys.size(); i++) {
            String key = paramKeys[i];

            if (params.getString(key) == null) {
                Log.e(TAG, String.format("%s is empty.", key));
                callbackContext.error(String.format("%s is empty.", key));
                return true;
            }
            req = params.getString(key);
        }
        req.packageValue = "Sign=WXPay";

        if (wxAPI.sendReq(req)) {
            Log.i(TAG, "Payment request has been sent successfully.");

            // send no result
            sendNoResultPluginResult(callbackContext);
        } else {
            Log.i(TAG, "Payment request has been sent unsuccessfully.");

            // send error
            callbackContext.error("Payment request has been sent unsuccessfully.");
        }
    }

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
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
