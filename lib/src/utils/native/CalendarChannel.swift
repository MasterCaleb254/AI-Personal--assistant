// CalendarChannel.swift
public class CalendarChannel: NSObject, FlutterPlugin {
  private let eventStore = EKEventStore()
  
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "ai.assistant/calendar", 
      binaryMessenger: registrar.messenger()
    )
    let instance = CalendarChannel()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getEvents":
      guard let args = call.arguments as? [String: Any],
            let start = args["start"] as? Double,
            let end = args["end"] as? Double else {
        result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments", details: nil))
        return
      }
      
      getEvents(
        start: Date(timeIntervalSince1970: start / 1000), 
        end: Date(timeIntervalSince1970: end / 1000), 
        result: result
      )
      
    case "createEvent":
      guard let args = call.arguments as? [String: Any] else {
        result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments", details: nil))
        return
      }
      createEvent(args: args, result: result)
      
    // Other methods...
      
    default:
      result(FlutterMethodNotImplemented)
    }
  }
  
  private func getEvents(start: Date, end: Date, result: @escaping FlutterResult) {
    let predicate = eventStore.predicateForEvents(
      withStart: start, 
      end: end, 
      calendars: nil
    )
    
    let events = eventStore.events(matching: predicate).map { event in
      return [
        "id": event.eventIdentifier,
        "title": event.title,
        "start": event.startDate.timeIntervalSince1970 * 1000,
        "end": event.endDate.timeIntervalSince1970 * 1000,
        "location": event.location ?? "",
        "notes": event.notes ?? ""
      ]
    }
    
    result(events)
  }
}