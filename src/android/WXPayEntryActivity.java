package __PACKAGE_NAME__;

import org.json.JSONObject;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;

import com.tencent.mm.opensdk.constants.ConstantsAPI;
import com.tencent.mm.opensdk.modelbase.BaseReq;
import com.tencent.mm.opensdk.modelbase.BaseResp;
import com.tencent.mm.opensdk.modelmsg.SendAuth;
import com.tencent.mm.opensdk.openapi.IWXAPIEventHandler;

import org.apache.cordova.CallbackContext;
import org.json.JSONException;

import daihere.cordova.plugin.Xpay;

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

    switch (resp.errCode) {
      case BaseResp.ErrCode.ERR_OK:
        switch (resp.getType()) {
          case ConstantsAPI.COMMAND_SENDAUTH:
              auth(resp);
              break;

          case ConstantsAPI.COMMAND_PAY_BY_WX:
          default:
              Xpay.currentCallbackContext.success();
              break;
        }
        break;
      case BaseResp.ErrCode.ERR_USER_CANCEL:
        Xpay.currentCallbackContext.error("The oder has been cancelled.");
        break;
      case BaseResp.ErrCode.ERR_AUTH_DENIED:
        Xpay.currentCallbackContext.error("Authorization failure.");
        break;
      case BaseResp.ErrCode.ERR_SENT_FAILED:
        Xpay.currentCallbackContext.error("Send failure.");
        break;
      case BaseResp.ErrCode.ERR_UNSUPPORT:
        Xpay.currentCallbackContext.error("Wechat not suport.");
        break;
      case BaseResp.ErrCode.ERR_COMM:
        Xpay.currentCallbackContext.error("Common error.");
        break;
      default:
        Xpay.currentCallbackContext.error("Unknow error.");
        break;
    }

    finish();
  }

  protected void auth(BaseResp resp) {
    SendAuth.Resp res = ((SendAuth.Resp) resp);

    Log.d(Xpay.TAG, res.toString());

    // get current callback context
    CallbackContext ctx = Xpay.currentCallbackContext;

    if (ctx == null) {
      return ;
    }

    JSONObject response = new JSONObject();
    try {
      response.put("code", res.code);
      response.put("state", res.state);
      response.put("country", res.country);
      response.put("lang", res.lang);
    } catch (JSONException e) {
      Log.e(Xpay.TAG, e.getMessage());
    }

    ctx.success(response);
  }
}
