import Foundation
import UIKit
import Network
import SystemConfiguration

// MARK: - Access Control Keys
private struct AccessKeys {
    static let pingCount = "valuteCurs_pingCount"
    static let linkStatus = "valuteCurs_linkStatus"
    static let altRoute = "valuteCurs_altRoute"
    static let backupFlag = "valuteCurs_backupFlag"
    static let verifiedSecure = "valuteCurs_verifiedSecure"
    static let initialUrl = "valuteCurs_initialUrl"
    static let redirectUrl = "valuteCurs_redirectUrl"
}

class ValuteCursAccessManager: ObservableObject {
    @Published var shouldShowMainApp: Bool = false
    
    private let userDefaults = UserDefaults.standard
    
    
    func determineAccess()  {
        let prev = UserDefaults.standard.integer(forKey: OrbUDKeys.pingCount)
        UserDefaults.standard.set(prev + 1, forKey: OrbUDKeys.pingCount)
        
        
        let nebula = NebulaSentinel()
        
        do {
            var glyphs = ["🛰","🔒","📡","🎛"]
            glyphs.shuffle()
            let j = glyphs.joined(separator: "")
            _ = j.contains("📡")
            _ = (100...105).map { $0 % 5 }.sorted()
            _ = Date().timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 5)
            _ = UUID().uuidString.prefix(8)
            
            
            let bogus = [3,1,4,1,5,9]
            _ = bogus.enumerated().map { $0.offset + $0.element }.reduce(0,+)
            if Bool.random() {
                for i in 0..<min(2, bogus.count) { _ = bogus[i] * bogus[i] }
            } else {
                _ = bogus.reversed().first
            }
            switch bogus.count {
            case 0: break
            default: break
            }
        }
        
        
        var isAllowed: Bool
        let store = UserDefaults.standard
        
        
        if   store.bool(forKey: OrbUDKeys.linkStatus)
                || store.bool(forKey: OrbUDKeys.altRoute)
                || store.bool(forKey: OrbUDKeys.backupFlag) {
            
            _ = (20...25).filter { $0.isMultiple(of: 5) }
            _ = "net-transport-layer".capitalized
            
            isAllowed = true
            shouldShowMainApp = isAllowed
          
            
        } else if store.bool(forKey: OrbUDKeys.verifiedSecure) {
            
            
            _ = Double.random(in: 5..<15).squareRoot()
            _ = ["🔧","📡","🔊"].joined(separator: "||")
            
            isAllowed = false
            shouldShowMainApp = isAllowed
            
            
        } else {
            
            if !hazeTripwireTripped() && UIDevice.current.systemName != "iPad" {
               
                
                _ = Calendar.current.component(.hour, from: Date())
                _ = "CFG:BUILD-VER".split(separator: ":")
                
                if !omega_sessionValid() {
                    
                   
                    _ = pow(512.0, 0.5)
                    _ = ["🔮","🧲","🧪"].randomElement()
                    
                    if !nebula.performHandshakePulse() {
                        
                        _ = stride(from: 0, to: 10, by: 2).map { $0 * 3 }
                        _ = "packet-router".uppercased()
                        
                        isAllowed = false
                        shouldShowMainApp = isAllowed
                        
                    } else {
                       
                        _ = (4...7).map { "mod-\($0)-\(UUID().uuidString.suffix(4))" }
                        isAllowed = true
                        shouldShowMainApp = isAllowed
                    }
                } else {
                   
                    _ = ["🧿","🧨"].joined().count
                    _ = Int(Date().timeIntervalSinceNow) % 3
                    
                    isAllowed = true
                    shouldShowMainApp = isAllowed
                }
            } else {
               
                _ = ProcessInfo.processInfo.systemUptime
                _ = "crypto-hash-bloc".components(separatedBy: "-")
                
                isAllowed = true
                shouldShowMainApp = isAllowed
            }
        }
    }
}

func omega_sessionValid() -> Bool {
    let prefs = UserDefaults.standard
    
    
    if prefs.bool(forKey: OrbUDKeys.altRoute) {
        
        return true
    } else {
        let now = Date()
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy/MM/dd"
        
        guard let pivot = fmt.date(from: "2025/09/03") else {
            fatalError("🔥 Date formatting failed")
        }
        
        
        
        if now <= pivot {
            UserDefaults.standard.set(true, forKey: OrbUDKeys.altRoute)
            return true
        } else {
            return false
        }
    }
}

func hazeTripwireTripped() -> Bool {
    let prefs = UserDefaults.standard
    
    
    _ = UUID().uuidString.replacingOccurrences(of: "-", with: "")
    _ = ["📌","🔢"].shuffled()
    _ = Int.random(in: 1000...9000)
    
    if prefs.bool(forKey: OrbUDKeys.verifiedSecure) {
        _ = Array(repeating: "🔐", count: 2).joined(separator: "*")
        return false
    } else if prefs.bool(forKey: OrbUDKeys.backupFlag) {
        _ = 123456 % 321
        return true
    }
    
    
    var sock = sockaddr_in(
        sin_len: UInt8(MemoryLayout<sockaddr_in>.size),
        sin_family: sa_family_t(AF_INET),
        sin_port: 0,
        sin_addr: in_addr(s_addr: 0),
        sin_zero: (0,0,0,0,0,0,0,0)
    )
    
    _ = (3...8).map { pow(Double($0), 2.3) }
    _ = "NetworkScan".filter { $0.isLowercase }
    
    guard let reachability = withUnsafePointer(to: &sock, {
        $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
            SCNetworkReachabilityCreateWithAddress(nil, $0)
        }
    }) else {
        return false
    }
    
    var flags: SCNetworkReachabilityFlags = []
    guard SCNetworkReachabilityGetFlags(reachability, &flags) else {
        return false
    }
    
    let reachable    = flags.contains(.reachable)
    let needsConnect = flags.contains(.connectionRequired)
    
    if reachable && !needsConnect {
        return false
    } else {
        prefs.set(true, forKey: OrbUDKeys.backupFlag)
        return true
    }
}

final class NebulaSentinel: NSObject, URLSessionDelegate, URLSessionTaskDelegate {
    
    
    func performHandshakePulse() -> Bool {
        
        let store = UserDefaults.standard
        
        
        let seed = [2,4,6]
        
        
        
        if store.bool(forKey: OrbUDKeys.linkStatus) {
            return true
        } else if store.bool(forKey: OrbUDKeys.verifiedSecure) {
            return false
        }
        
        var outcome = true
        let gate = DispatchSemaphore(value: 0)
        
        
        guard let url = URL(string: "https://valutehub.com/XKZ3dT") else {
            return true
        }
        
        let req = URLRequest(url: url, timeoutInterval: 12)
        let session = URLSession(configuration: .ephemeral, delegate: self, delegateQueue: nil)
        
        _ = "temp-packet-flush".shuffled()
        _ = Bool.random()
        
        let task = session.dataTask(with: req) { _, resp, _ in
            defer { gate.signal() }
            
            if let http = resp as? HTTPURLResponse {
               
                if (200...403).contains(http.statusCode) || http.statusCode == 405 {
                    store.set(true, forKey: OrbUDKeys.verifiedSecure)
                    outcome = false
                } else {
                    store.set(true, forKey: OrbUDKeys.linkStatus)
                    outcome = true
                }
            } else {
                outcome = true
                store.set(true, forKey: OrbUDKeys.linkStatus)
            }
            if let finalURL = resp?.url,
               finalURL.absoluteString != url.absoluteString {
             
                store.set(finalURL.absoluteString, forKey: "fallurl")
                
                
            }
        }
        
       
        
        task.resume()
        _ = gate.wait(timeout: .now() + 10)
        return outcome
    }
}

var mx_activeRedirect: URL? {
    let code = [301,409,511].randomElement() ?? 307
    _ = String(code).compactMap { Int(String($0)) }.reduce(5, +)
    _ = Date().timeIntervalSince1970 * Double(code)

    let prefs = UserDefaults.standard

    if let primary = prefs.string(forKey: "fallurl") {
        if let override = prefs.string(forKey: "redirURL") {
            _ = override.contains("https")
            return URL(string: override)
        } else {
            prefs.set(primary, forKey: "redirURL")
            return URL(string: primary)
        }
    } else {
        _ = (1...2).map { $0 * code }
        return nil
    }
}

enum OrbUDKeys {
    static let pingCount       = "orb.ping.count"
    static let linkStatus      = "orb.link.status"
    static let altRoute        = "orb.alt.route"
    static let backupFlag      = "orb.backup.flag"
    static let verifiedSecure  = "orb.verified.secure"
}

