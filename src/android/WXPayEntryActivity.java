package __PACKAGE_NAME__;

import org.apache.cordova.PluginResult;
import org.json.JSONObject;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;

import com.tencent.mm.sdk.constants.ConstantsAPI;
import com.tencent.mm.sdk.modelbase.BaseReq;
import com.tencent.mm.sdk.modelbase.BaseResp;
import com.tencent.mm.sdk.openapi.IWXAPIEventHandler;

import cordova.plugin.Xpay;

public class WXPayEntryActivity extends Activity implements IWXAPIEventHandler{
  
  private static final String LOG_TAG = WXPayEntryActivity.class.getSimpleName();
  
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        Xpay.wxAPI.handleIntent(getIntent(), this);
    }

  @Override
  protected void onNewIntent(Intent intent) {
    super.onNewIntent(intent);
    setIntent(intent);
    Xpay.wxAPI.handleIntent(intent, this);
  }

  @Override
  public void onReq(BaseReq req) {
    finish();
  }

  @Override
  public void onResp(BaseResp resp) {
    Log.d(LOG_TAG, "onPayFinish, errCode = " + resp.errCode);

    if (resp.getType() == ConstantsAPI.COMMAND_PAY_BY_WX) {
      
    	JSONObject json = new JSONObject();
    	
    	try {
	    	if (resp.errStr != null && resp.errStr.length() >= 0) {
	    		json.put("errStr", resp.errStr);
	    	} else {
	    		json.put("errStr", "");
	    	}
	    	json.put("code", resp.errCode);
    	} catch (Exception e) {
    		Log.e(LOG_TAG, e.getMessage(), e);
    	}

        PluginResult result = null;
        if (0 == resp.errCode) {
          result = new PluginResult(PluginResult.Status.OK, json.toString());
        } else {
          result = new PluginResult(PluginResult.Status.ERROR, json.toString());
        }
        result.setKeepCallback(true);
        Xpay.currentCallbackContext.sendPluginResult(result);
    }

    finish();
  }
}