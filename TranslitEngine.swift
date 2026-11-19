import Foundation

struct TranslitResult {
    let deleteBackwardCount: Int
    let outputText: String
}

enum TranslitLanguage: String, CaseIterable {
    case ru = "RU"
    case uk = "UK"
    case be = "BE"
    case mk = "MK"
    case cu = "CU"
    case el = "EL"
    case hy = "HY"
    case ka = "KA"
    case en = "EN"
}

class TranslitEngine {
    static let shared = TranslitEngine()
    var currentLanguage: TranslitLanguage = .ru
    
    var isTranslitEnabled: Bool {
        return currentLanguage != .en
    }
    
    func cycleNextLanguage() -> String {
        let all = TranslitLanguage.allCases
        if let idx = all.firstIndex(of: currentLanguage) {
            currentLanguage = all[(idx + 1) % all.count]
        }
        return currentLanguage.rawValue
    }
    
    // Rules map: [Language: [TypedSequence: Replacement]]
    // Supports multi-character sequences like "sh" -> "ш", "shh" -> "щ", "ya" -> "я"
    private let rules: [TranslitLanguage: [String: String]] = [
        .ru: [
            "a":"а", "b":"б", "v":"в", "g":"г", "d":"д", "e":"е", "yo":"ё", "jo":"ё",
            "zh":"ж", "z":"з", "i":"и", "j":"й", "k":"к", "l":"л", "m":"м", "n":"н",
            "o":"о", "p":"п", "r":"р", "s":"с", "t":"т", "u":"у", "f":"ф", "h":"х",
            "x":"х", "c":"ц", "ts":"ц", "ch":"ч", "sh":"ш", "shh":"щ", "w":"щ",
            "''":"ъ", "y":"ы", "'":"ь", "je":"э", "eh":"э", "yu":"ю", "ju":"ю",
            "ya":"я", "ja":"я",
            // Uppercase
            "A":"А", "B":"Б", "V":"В", "G":"Г", "D":"Д", "E":"Е", "Yo":"Ё", "YO":"Ё",
            "Zh":"Ж", "ZH":"Ж", "Z":"З", "I":"И", "J":"Й", "K":"К", "L":"Л", "M":"М",
            "N":"Н", "O":"О", "P":"П", "R":"Р", "S":"С", "T":"Т", "U":"У", "F":"Ф",
            "H":"Х", "X":"Х", "C":"Ц", "Ts":"Ц", "TS":"Ц", "Ch":"Ч", "CH":"Ч",
            "Sh":"Ш", "SH":"Ш", "Shh":"Щ", "SHH":"Щ", "W":"Щ", "Y":"Ы",
            "Je":"Э", "JE":"Э", "Eh":"Э", "EH":"Э", "Yu":"Ю", "YU":"Ю",
            "Ya":"Я", "YA":"Я"
        ],
        .uk: [
            "a":"а", "b":"б", "v":"в", "g":"ґ", "h":"г", "d":"д", "e":"е", "ye":"є",
            "je":"є", "zh":"ж", "z":"з", "y":"и", "i":"і", "yi":"ї", "ji":"ї", "j":"й",
            "k":"к", "l":"л", "m":"м", "n":"н", "o":"о", "p":"п", "r":"р", "s":"с",
            "t":"т", "u":"у", "f":"ф", "kh":"х", "x":"х", "c":"ц", "ts":"ц", "ch":"ч",
            "sh":"ш", "shh":"щ", "w":"щ", "'":"ь", "yu":"ю", "ju":"ю", "ya":"я", "ja":"я",
            "A":"А", "B":"Б", "V":"В", "G":"Ґ", "H":"Г", "D":"Д", "E":"Е", "Ye":"Є",
            "YE":"Є", "Zh":"Ж", "ZH":"Ж", "Z":"З", "Y":"И", "I":"І", "Yi":"Ї", "YI":"Ї",
            "J":"Й", "K":"К", "L":"Л", "M":"М", "N":"Н", "O":"О", "P":"П", "R":"Р",
            "S":"С", "T":"Т", "U":"У", "F":"Ф", "Kh":"Х", "KH":"Х", "X":"Х", "C":"Ц",
            "Ch":"Ч", "CH":"Ч", "Sh":"Ш", "SH":"Ш", "Shh":"Щ", "SHH":"Щ", "Yu":"Ю",
            "YU":"Ю", "Ya":"Я", "YA":"Я"
        ],
        .be: [
            "a":"а", "b":"б", "v":"в", "g":"ґ", "h":"г", "d":"д", "e":"е", "yo":"ё",
            "jo":"ё", "zh":"ж", "z":"з", "i":"і", "j":"й", "k":"к", "l":"л", "m":"м",
            "n":"н", "o":"о", "p":"п", "r":"р", "s":"с", "t":"т", "u":"у", "w":"ў",
            "f":"ф", "kh":"х", "x":"х", "c":"ц", "ts":"ц", "ch":"ч", "sh":"ш", "y":"ы",
            "'":"ь", "eh":"э", "yu":"ю", "ju":"ю", "ya":"я", "ja":"я",
            "A":"А", "B":"Б", "V":"В", "G":"Ґ", "H":"Г", "D":"Д", "E":"Е", "Yo":"Ё",
            "Zh":"Ж", "Z":"З", "I":"І", "J":"Й", "K":"К", "L":"Л", "M":"М", "N":"Н",
            "O":"О", "P":"П", "R":"Р", "S":"С", "T":"Т", "U":"У", "W":"Ў", "F":"Ф",
            "Kh":"Х", "X":"Х", "C":"Ц", "Ch":"Ч", "Sh":"Ш", "Y":"Ы", "Eh":"Э",
            "Yu":"Ю", "Ya":"Я"
        ],
        .mk: [
            "a":"а", "b":"б", "v":"в", "g":"г", "d":"д", "gj":"ѓ", "e":"е", "zh":"ж",
            "z":"з", "dz":"ѕ", "i":"и", "j":"ј", "k":"к", "l":"л", "lj":"љ", "m":"м",
            "n":"н", "nj":"њ", "o":"о", "p":"п", "r":"р", "s":"с", "t":"т", "kj":"ќ",
            "u":"у", "f":"ф", "h":"х", "c":"ц", "ch":"ч", "dj":"џ", "sh":"ш",
            "A":"А", "B":"Б", "V":"В", "G":"Г", "D":"Д", "Gj":"Ѓ", "E":"Е", "Zh":"Ж",
            "Z":"З", "Dz":"Ѕ", "I":"И", "J":"Ј", "K":"К", "L":"Л", "Lj":"Љ", "M":"М",
            "N":"Н", "Nj":"Њ", "O":"О", "P":"П", "R":"Р", "S":"С", "T":"Т", "Kj":"Ќ",
            "U":"У", "F":"Ф", "H":"Х", "C":"Ц", "Ch":"Ч", "Dj":"Џ", "Sh":"Ш"
        ],
        .cu: [
            "a":"а", "b":"б", "v":"в", "g":"г", "d":"д", "e":"є", "zh":"ж", "dz":"ѕ",
            "z":"з", "i":"и", "yi":"і", "k":"к", "l":"л", "m":"м", "n":"н", "o":"о",
            "p":"п", "r":"р", "s":"с", "t":"т", "u":"ѹ", "f":"ф", "kh":"х", "w":"ѡ",
            "c":"ц", "ch":"ч", "sh":"ш", "sht":"щ", "''":"ъ", "y":"ы", "'":"ь",
            "eh":"ѣ", "yu":"ю", "ya":"ꙗ", "th":"ѳ",
            "A":"А", "B":"Б", "V":"В", "G":"Г", "D":"Д", "E":"Є", "Zh":"Ж", "Dz":"Ѕ",
            "Z":"З", "I":"И", "Yi":"І", "K":"К", "L":"Л", "M":"М", "N":"Н", "O":"О",
            "P":"П", "R":"Р", "S":"С", "T":"Т", "U":"Ѹ", "F":"Ф", "Kh":"Х", "W":"Ѡ",
            "C":"Ц", "Ch":"Ч", "Sh":"Ш", "Sht":"Щ", "Y":"Ы", "Eh":"Ѣ", "Yu":"Ю",
            "Ya":"Ꙗ", "Th":"Ѳ"
        ],
        .el: [
            "a":"α", "b":"β", "g":"γ", "d":"δ", "e":"ε", "z":"ζ", "h":"η", "th":"θ",
            "i":"ι", "k":"κ", "l":"λ", "m":"μ", "n":"ν", "x":"ξ", "o":"ο", "p":"π",
            "r":"ρ", "s":"σ", "t":"τ", "y":"υ", "u":"υ", "ph":"φ", "f":"φ", "ch":"χ",
            "ps":"ψ", "w":"ω",
            "A":"Α", "B":"Β", "G":"Γ", "D":"Δ", "E":"Ε", "Z":"Ζ", "H":"Η", "Th":"Θ",
            "I":"Ι", "K":"Κ", "L":"Λ", "M":"Μ", "N":"Ν", "X":"Ξ", "O":"Ο", "P":"Π",
            "R":"Ρ", "S":"Σ", "T":"Τ", "Y":"Υ", "U":"Υ", "Ph":"Φ", "F":"Φ", "Ch":"Χ",
            "Ps":"Ψ", "W":"Ω"
        ],
        .hy: [
            "a":"ա", "b":"բ", "g":"գ", "d":"դ", "e":"ե", "z":"զ", "eh":"է", "y":"ը",
            "th":"թ", "zh":"ժ", "i":"ի", "l":"լ", "kh":"խ", "ts":"ծ", "k":"կ", "h":"հ",
            "dz":"ձ", "gh":"ղ", "ch":"ճ", "m":"մ", "j":"յ", "n":"ն", "sh":"շ", "o":"ո",
            "chh":"չ", "p":"պ", "jh":"ջ", "rr":"ռ", "s":"ս", "v":"վ", "t":"տ", "r":"ր",
            "c":"ց", "w":"ւ", "ph":"փ", "q":"ք", "ev":"և", "oo":"օ", "f":"ֆ",
            "A":"Ա", "B":"Բ", "G":"Գ", "D":"Դ", "E":"Ե", "Z":"Զ", "Eh":"Է", "Y":"Ը",
            "Th":"Թ", "Zh":"Ժ", "I":"Ի", "L":"Լ", "Kh":"Խ", "Ts":"Ծ", "K":"Կ", "H":"Հ",
            "Dz":"Ձ", "Gh":"Ղ", "Ch":"Ճ", "M":"Մ", "J":"Յ", "N":"Ն", "Sh":"Շ", "O":"Ո",
            "Chh":"Չ", "P":"Պ", "Jh":"Ջ", "Rr":"Ռ", "S":"Ս", "V":"Վ", "T":"Տ", "R":"Ր",
            "C":"Ց", "W":"Ւ", "Ph":"Փ", "Q":"Ք", "Oo":"Օ", "F":"Ֆ"
        ],
        .ka: [
            "a":"ა", "b":"ბ", "g":"გ", "d":"დ", "e":"ე", "v":"ვ", "z":"ზ", "t":"თ",
            "i":"ი", "k'":"კ", "l":"ლ", "m":"მ", "n":"ნ", "o":"ო", "p'":"პ", "zh":"ჟ",
            "r":"რ", "s":"ს", "t'":"ტ", "u":"უ", "p":"ფ", "k":"ქ", "gh":"ღ", "q":"ყ",
            "sh":"შ", "ch":"ჩ", "ts":"ც", "dz":"ძ", "ts'":"წ", "ch'":"ჭ", "kh":"ხ",
            "j":"ჯ", "h":"ჰ"
        ]
    ]
    
    // Tracks the last 3 raw Latin characters typed so digraphs/trigraphs like "sh" -> "ш" work
    private var recentLatin = ""
    
    func resetBuffer() {
        recentLatin = ""
    }
    
    func processInput(_ input: String, contextBefore: String) -> TranslitResult {
        guard isTranslitEnabled, let langRules = rules[currentLanguage] else {
            return TranslitResult(deleteBackwardCount: 0, outputText: input)
        }
        
        if input == " " || input == "\n" {
            resetBuffer()
            return TranslitResult(deleteBackwardCount: 0, outputText: input)
        }
        
        let candidate = recentLatin + input
        
        // Check 3-char match first (e.g., "shh" -> "щ", "chh" -> "չ")
        if candidate.count >= 3 {
            let last3 = String(candidate.suffix(3))
            if let mapped = langRules[last3] {
                recentLatin = last3
                return TranslitResult(deleteBackwardCount: 1, outputText: mapped)
            }
        }
        
        // Check 2-char match next (e.g., "sh" -> "ш", "ya" -> "я")
        if candidate.count >= 2 {
            let last2 = String(candidate.suffix(2))
            if let mapped = langRules[last2] {
                recentLatin = last2
                return TranslitResult(deleteBackwardCount: 1, outputText: mapped)
            }
        }
        
        // Single-char match
        if let mapped = langRules[input] {
            recentLatin = input
            return TranslitResult(deleteBackwardCount: 0, outputText: mapped)
        }
        
        resetBuffer()
        return TranslitResult(deleteBackwardCount: 0, outputText: input)
    }
}
