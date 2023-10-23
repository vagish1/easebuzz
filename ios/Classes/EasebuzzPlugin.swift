import Flutter
import UIKit

public class EasebuzzPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "easebuzz", binaryMessenger: registrar.messenger())
    let instance = EasebuzzPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    case "openPaymentGateway":
        
        self?.payResult = result;
        self?.initiatePaymentAction(call: call);
      
    default:
      result(FlutterMethodNotImplemented)
    }
  }
    
    var payResult:FlutterResult
    
    func initiatePaymentAction(call:FlutterMethodCall) {
    if let orderDetails = call.arguments as? [String:String]{
    let payment = Payment.init(customerData: orderDetails)
    let paymentValid = payment.isValid().validity
    if !paymentValid {
    print("Invalid records")
    } else{
    PayWithEasebuzz.setUp(pebCallback: self )
    PayWithEasebuzz.invokePaymentOptionsView(paymentObj: payment, isFrom: self)
    }
    }else{
    // handle error
    let dict = self.setErrorResponseDictError("Empty error", errorMessage: "Invalid validation", result: "Invalid request")
    self.payResult(dict)
    }
    }

    // payment call callback and handle response
    func PEBCallback(data: [String : AnyObject]) {
    if data.count > 0 {
    self.payResult(data)
    }else{
    let dict = self.setErrorResponseDictError("Empty error", errorMessage: "Empty payment response", result: "payment_failed")
    self.payResult(dict)
    }
    }

    // Create error response dictionary that the time of something went wrong
    func setErrorResponseDictError(_ error: String?, errorMessage: String?, result: String?) -> [AnyHashable : Any]? {
    var dict: [AnyHashable : Any] = [:]
    var dictChild: [AnyHashable : Any] = [:]
    dictChild["error"] = "\(error ?? "")"
    dictChild["error_msg"] = "\(errorMessage ?? "")"
    dict["result"] = "\(result ?? "")"
    dict["payment_response"] = dictChild
    return dict
    }
}
