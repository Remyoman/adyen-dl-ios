import AdyenDL
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true



//  Merchant URLs.
let paymentSignatureURL =           //  PROVIDE URL
let paymentResultSignatureURL =     //  PROVIDE URL
let paymentStatusURL =              //  PROVIDE URL



//  Configure 'Payments Processor'.
let configuration = Configuration(
    environment: .live,
    paymentSignatureURL: URL(string: paymentSignatureURL)!,
    paymentResultSignatureURL: URL(string: paymentResultSignatureURL)!,
    paymentStatusURL: URL(string: paymentStatusURL)!
)

let paymentsProcessor = PaymentsProcessor(configuration: configuration)



//  Create 'Payment'.
let payment = Payment(
    amount: 1,
    currency: "EUR",
    country: "NL"
)



//  Fetch available payment methods.
paymentsProcessor.fetchPaymentMethodsFor(payment) { (methods, error) in
    guard let methods = methods else { return }
    
    
    //  Present payment methods in UI.
    methods
    
    
    
    //  Fetch 'Payment URL' for selected payment method.
    let selectedMethod = methods[1].issuers![0]
    
    paymentsProcessor.fetchPayURLFor(payment, payingWith: selectedMethod, completion: { (url, error) in
        
        
        //  Open 'Payment URL' in a browser.
        url
        
        
        
        error
    })
    
}
