import SwiftUI

private enum QQGiftArtwork {
  static let names: [String: String] = [
    "抹茶绵绵冰": "gift_pic32",
    "love气球": "gift_pic03",
    "吉他": "gift_pic16",
    "情书": "gift_pic02",
    "爱心": "gift_pic01",
    "网球": "gift_pic12",
    "风铃": "gift_pic09",
    "乒乓球": "gift_pic10",
    "冰淇凌": "gift_pic04",
    "小白鹅": "gift_pic22",
    "巧克力": "gift_pic29",
    "手捧花": "gift_pic40",
    "拍立得": "gift_pic19",
    "手风琴": "gift_pic17",
    "摩天轮": "gift_pic34",
    "泰迪熊": "gift_pic08",
    "独角兽": "gift_pic23",
    "棉花糖可可": "gift_pic26",
    "羽毛球": "gift_pic11",
    "莲花灯": "gift_pic21",
    "郁金香": "gift_pic20",
    "樱花冰酪碗": "gift_pic33",
    "毛毡小兔子": "gift_pic24",
    "中式套餐": "gift_pic38",
    "气球独角兽": "gift_pic07",
    "复古跑车": "gift_pic28",
    "旋转木马": "gift_pic41",
    "梦幻城堡": "gift_pic42",
    "树莓蛋糕": "gift_pic27",
    "汉堡套餐": "gift_pic37",
    "海盐蓝调": "gift_pic25",
    "烤肉套餐": "gift_pic39",
    "焦糖布丁": "gift_pic05",
    "珍珠奶茶": "gift_pic15",
    "电动钢琴": "gift_pic18",
    "草莓冰沙": "gift_pic31",
    "草莓奶昔": "gift_pic14",
    "薄巧冰饮": "gift_pic13",
    "阳光沙滩": "gift_pic35",
    "露营帐篷": "gift_pic36",
    "草莓舒芙蕾": "gift_pic06",
    "丘比特之箭": "gift_pic30"
  ]
}

struct QQGiftView: View {
  @EnvironmentObject private var store: QingqingStore
  @Environment(\.dismiss) private var dismiss
  let role: QQRecord
  @State private var gifts: [QQRecord] = []
  @State private var selected: QQRecord?
  @State private var confirming = false
  @State private var error: String?
  @State private var busy = false
  @State private var unknown = false
  private var pendingKey: String { "qingqing.gift.pending.\(store.user?.id ?? "guest").\(role.id)" }
  var body: some View {
    VStack(spacing: 0) {
      ZStack(alignment: .topTrailing) {
        Text("送礼物").font(.system(size: 20, weight: .bold)).frame(maxWidth: .infinity).padding(.top, 40)
        Button { dismiss() } label: { QQArtwork(name: "pop_ico_close").frame(width: 32, height: 32) }.padding(.trailing, 20).padding(.top, 10).accessibilityLabel("关闭")
      }
      HStack(spacing: 4) {
        Text("送礼物给").font(.system(size: 14)).foregroundStyle(.gray)
        HStack(spacing: 4) { QQRemoteImage(address: role.image).frame(width: 18, height: 18).clipShape(Circle()); Text(role.name).font(.system(size: 14)).lineLimit(1) }.padding(.leading, 7).padding(.trailing, 12).frame(height: 30).background(Color(white: 235.0/255), in: Capsule())
        Spacer(minLength: 4)
        NavigationLink { QQMemberView(initialTab: 1) } label: { HStack(spacing: 4) { QQArtwork(name: "chatset_ico_diamond").frame(width: 14, height: 14); Text(store.user?["coin"] ?? "").font(.system(size: 14)); Image(systemName: "chevron.right").font(.system(size: 12)).foregroundStyle(.gray) }.padding(.horizontal, 10).frame(height: 30).background(Color(white: 235.0/255), in: Capsule()) }
      }.padding(.horizontal, 20).padding(.top, 20)
      ScrollView {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3), spacing: 10) {
          ForEach(gifts) { gift in
            Button { selected = gift } label: {
              VStack(spacing: 8) {
                Group { if let artwork = QQGiftArtwork.names[gift.name] { QQArtwork(name: artwork) } else { QQRemoteImage(address: gift.first("img_url", "image_url", "image"), contentMode: .fit) } }.frame(width: 70, height: 70)
                HStack(spacing: 1) { Text(gift["coin"]).font(.system(size: 13, weight: .bold)); QQArtwork(name: "gif_ico_diamond").frame(width: 8, height: 8) }.padding(.horizontal, 8).frame(height: 17).background(Color(red: 253.0/255, green: 221.0/255, blue: 249.0/255), in: Capsule())
                Text(gift.name).font(.system(size: 12)).lineLimit(1)
              }.padding(.vertical, 13).frame(maxWidth: .infinity).background(.white, in: RoundedRectangle(cornerRadius: 18)).overlay { if selected?.id == gift.id { RoundedRectangle(cornerRadius: 18).stroke(LinearGradient(colors: [Color(red: 182.0/255, green: 145.0/255, blue: 253.0/255), Color(red: 105.0/255, green: 191.0/255, blue: 250.0/255), Color(red: 140.0/255, green: 242.0/255, blue: 227.0/255)], startPoint: .top, endPoint: .bottom), lineWidth: 3) } }
            }.buttonStyle(.plain).disabled(busy)
          }
        }.padding(.horizontal, 20).padding(.vertical, 10)
      }.padding(.top, 16)
      if let error { Text(error).font(.system(size: 12)).foregroundStyle(.red).padding(.horizontal, 20) }
      Button { confirming = true } label: { Text(busy ? "赠送中…" : "赠送").font(.system(size: 16, weight: .bold)).frame(maxWidth: .infinity).frame(height: 56).background(LinearGradient(colors: [Color(red: 140.0/255, green: 242.0/255, blue: 227.0/255), Color(red: 182.0/255, green: 145.0/255, blue: 253.0/255), Color(red: 105.0/255, green: 191.0/255, blue: 250.0/255)], startPoint: .leading, endPoint: .trailing), in: Capsule()) }.disabled(selected == nil || busy || unknown).padding(.horizontal, 20).padding(.top, 10).padding(.bottom, 20)
    }.background(QQStyle.background).foregroundStyle(QQStyle.ink).toolbar(.hidden, for: .navigationBar).presentationDetents([.fraction(0.9)]).presentationCornerRadius(30)
      .task {
        unknown = UserDefaults.standard.object(forKey: pendingKey) != nil
        if unknown { error = "上次赠送结果尚未确认，请先核实钻石明细，避免重复赠送。" }
        do { gifts = try await store.api.request("role/getGift").records; selected = gifts.first } catch { self.error = error.localizedDescription }
      }
      .confirmationDialog("确认赠送？", isPresented: $confirming, titleVisibility: .visible) {
        if let selected { Button("赠送\(selected.name)（\(selected["coin"])钻石）") { Task { await send(selected) } } }
      }
  }
  private func send(_ gift: QQRecord) async {
    guard !busy, !unknown else { return }
    busy = true; error = nil
    UserDefaults.standard.set(gift.id, forKey: pendingKey)
    defer { busy = false }
    do {
      _ = try await store.api.request("role/sendGift", method: "POST", parameters: ["gift_id": gift.id, "role_id": role.id])
      UserDefaults.standard.removeObject(forKey: pendingKey)
      await store.refreshUser(); dismiss()
    } catch let failure as QQAPIError {
      if case .service(let code, _) = failure, code > 0 { UserDefaults.standard.removeObject(forKey: pendingKey) } else { unknown = true }
      error = failure.localizedDescription
    } catch { unknown = true; self.error = "赠送结果尚未确认，请先核实钻石明细，避免重复赠送。" }
  }
}

struct QQIntimacyView: View {
  @EnvironmentObject private var store: QingqingStore
  let role: QQRecord
  @State private var info: QQValue = .null
  @State private var configuration: QQValue = .null
  @State private var rules: QQValue = .null
  @State private var error: String?
  @State private var showingRules = false
  @State private var showingGift = false
  @State private var showingBoost = false
  @State private var confirmingBoost = false
  @State private var buying = false
  @State private var unknown = false
  private var progress: QQIntimacyProgress { QQIntimacyProgress(value: Int(info["intimacy"].text) ?? 0, configuration: configuration) }
  private let names = ["初识", "熟悉", "靠近", "默契", "信任", "亲密", "羁绊"]
  private let descriptions = ["初识等级，你们正在建立最初的印象…", "熟悉等级，你们开始建立更深的联系…", "靠近等级，你们的关系越来越近了…", "默契等级，你们开始心有灵犀…", "信任等级，你们彼此相互信赖…", "亲密等级，你们已经亲密无间…", "羁绊等级，你们建立了深厚的情感羁绊…"]
  private let colors: [Color] = [Color(red: 61.0/255, green: 209.0/255, blue: 1), Color(red: 166.0/255, green: 176.0/255, blue: 1), Color(red: 111.0/255, green: 169.0/255, blue: 1), Color(red: 223.0/255, green: 175.0/255, blue: 1), Color(red: 1, green: 218.0/255, blue: 124.0/255), Color(red: 1, green: 157.0/255, blue: 208.0/255), Color(red: 1, green: 108.0/255, blue: 108.0/255)]
  private var tint: Color { colors[progress.stage - 1] }
  private var pendingKey: String { "qingqing.boost.pending.\(store.user?.id ?? "guest").\(role.id)" }
  var body: some View {
    QQPage(title: "", color: .clear, backgroundArtwork: String(format: "lv_bg%02d", progress.stage), artworkHeight: 216) {
      ScrollView {
        VStack(alignment: .leading, spacing: 0) {
          HStack(spacing: 12) {
            QQArtwork(name: String(format: "lv_ico_heart%02d", progress.stage)).frame(width: 66, height: 66).overlay(alignment: .top) { Text("Lv.\(progress.level)").font(.system(size: 20, weight: .bold)).foregroundStyle(.white).padding(.top, 14) }
            Text(progress.stageName).font(.system(size: 18, weight: .bold))
          }.padding(.leading, 40).padding(.top, 16).padding(.bottom, 40)
          ForEach(0..<min(7, progress.stage + 2), id: \.self) { stage in timeline(stage) }
          if progress.stage < 7 { timelineMore }
          if let error { Text(error).font(.system(size: 12)).foregroundStyle(.red).padding(20) }
        }.padding(.top, 8).padding(.bottom, 30)
      }
    }.background { Image("qq_lv_bg00").resizable().ignoresSafeArea() }.overlay(alignment: .topTrailing) { Button { showingRules = true } label: { Image(systemName: "info.circle.fill").font(.system(size: 18)).foregroundStyle(.gray.opacity(0.6)).frame(width: 50, height: 50) }.accessibilityLabel("亲密度规则") }
      .task {
        unknown = UserDefaults.standard.object(forKey: pendingKey) != nil
        if unknown { error = "上次购买结果尚未确认，请先核实钻石明细。" }
        do {
          info = try await store.api.request("role/getMemberRole", parameters: ["role_id": role.id])
          configuration = try await store.api.request("role/getConfig")
          rules = try await store.api.request("role/getRoleTips")
        } catch { self.error = error.localizedDescription }
      }
      .sheet(isPresented: $showingRules) { rulesSheet }
      .sheet(isPresented: $showingGift) { NavigationStack { QQGiftView(role: role) } }
      .overlay { if showingBoost { boostOverlay } }
      .confirmationDialog("确认购买亲密度暴击卡？", isPresented: $confirmingBoost, titleVisibility: .visible) { Button("\(rules["double_card"]["buy"].text) 钻石购买") { Task { await buyBoost() } } }
  }
  private func timeline(_ stage: Int) -> some View {
    let current = stage == progress.stage - 1
    let future = stage > progress.stage - 1
    return HStack(alignment: .top, spacing: 10) {
      VStack(spacing: 4) {
        QQArtwork(name: String(format: "lv_ico_tittle%02d", future ? 0 : stage + 1)).frame(width: 14, height: 26)
        QQTimelineLine().stroke(future ? Color(white: 0.84) : colors[stage], style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [2, 4])).frame(maxHeight: .infinity)
      }.frame(width: 30)
      VStack(alignment: .leading, spacing: 10) {
        HStack(spacing: 0) {
          Text(names[stage] + "-你们开始认识彼此").font(.system(size: 14, weight: .bold)).padding(.leading, 12).frame(height: 26).background(alignment: .leading) { UnevenRoundedRectangle(topLeadingRadius: 15, bottomLeadingRadius: 15).fill(LinearGradient(colors: [colors[stage], colors[stage].opacity(0)], startPoint: .leading, endPoint: .trailing)).frame(width: 158) }.fixedSize(horizontal: true, vertical: false)
          Spacer(minLength: 2)
          if future { Label("尚未解锁", systemImage: "lock.fill").font(.system(size: 12)).foregroundStyle(.gray).lineLimit(1).minimumScaleFactor(0.7) }
        }
        Text(descriptions[stage]).font(.system(size: 13)).foregroundStyle(Color(white: 0.62)).padding(.leading, 8)
        if current { currentCard.padding(.top, 5) }
      }.padding(.bottom, 30)
    }.padding(.leading, 5).padding(.trailing, 20).fixedSize(horizontal: false, vertical: true)
  }
  private var currentCard: some View {
    VStack(spacing: 8) {
      HStack(spacing: 10) {
        ZStack { Circle().stroke(Color(white: 0.95), lineWidth: 5); Text("\(progress.percent)").font(.system(size: 10, weight: .bold)).foregroundStyle(tint) }.frame(width: 26, height: 26)
        VStack(alignment: .leading, spacing: 4) {
          Text("当前进度\(progress.percent)%").font(.system(size: 14, weight: .bold))
          Text(info["double_card_time"].text.isEmpty || (Double(info["double_card_time"].text) ?? 0) <= (Double(info["server_time"].text) ?? 0) ? "亲密度\(progress.value)，还差\(progress.need)可升级" : "亲密度\(progress.value)，x2倍暴击中").font(.system(size: 10)).foregroundStyle(Color(white: 0.62))
        }.frame(maxWidth: .infinity, alignment: .leading)
        Button { showingBoost = true } label: { Text("去加速").font(.system(size: 12, weight: .bold)).foregroundStyle(.white).frame(width: 60, height: 30).background(tint, in: Capsule()) }.disabled(rules["double_card"].isNull || unknown).padding(.trailing, 10)
      }.frame(height: 38)
      HStack(spacing: 6) {
        QQArtwork(name: "lv_ico_gift").frame(width: 38, height: 38)
        VStack(alignment: .leading, spacing: 4) { Text("送礼物，提升亲密度").font(.system(size: 13)); Text("每次可提升大量亲密度").font(.system(size: 10)).foregroundStyle(Color(white: 0.62)) }.frame(maxWidth: .infinity, alignment: .leading)
        Button { showingGift = true } label: { Text("送礼物").font(.system(size: 12, weight: .bold)).foregroundStyle(.white).frame(width: 60, height: 30).background(tint, in: Capsule()) }
      }.padding(.leading, 14).padding(.trailing, 10).frame(height: 62).background(tint.opacity(0.035), in: RoundedRectangle(cornerRadius: 15))
      VStack(alignment: .leading, spacing: 8) {
        Text("最近的变化").foregroundStyle(Color(white: 0.62))
        ForEach(Array(info["middle_text"].list.prefix(3).enumerated()), id: \.offset) { _, text in bullet(text.text) }
      }.font(.system(size: 13)).frame(maxWidth: .infinity, alignment: .leading).padding(12).background(tint.opacity(0.035), in: RoundedRectangle(cornerRadius: 15))
      VStack(alignment: .leading, spacing: 8) { Text("默契正在形成").font(.system(size: 13)).foregroundStyle(Color(white: 0.62)); bullet(info["bottom_text"].text.isEmpty ? "继续相处，关系会自然发展" : info["bottom_text"].text) }.frame(maxWidth: .infinity, alignment: .leading).padding(12).background(tint.opacity(0.035), in: RoundedRectangle(cornerRadius: 15))
    }.padding(12).background(.white, in: RoundedRectangle(cornerRadius: 22))
  }
  private func bullet(_ text: String) -> some View { HStack(alignment: .top, spacing: 4) { QQArtwork(name: String(format: "lv_ico_point%02d", progress.stage)).frame(width: 7, height: 16); Text(text).font(.system(size: 13)).lineSpacing(4) } }
  private var timelineMore: some View {
    HStack(alignment: .top, spacing: 10) { VStack(spacing: 4) { QQArtwork(name: "lv_ico_tittle00").frame(width: 14, height: 26); QQTimelineLine().stroke(Color(white: 0.84), style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [2, 4])) }.frame(width: 30); Text("更多等待你的解锁").font(.system(size: 14, weight: .bold)).padding(.leading, 12).frame(height: 26).background(LinearGradient(colors: [Color(white: 0.9), .clear], startPoint: .leading, endPoint: .trailing), in: Capsule()); Spacer() }.frame(height: 80).padding(.leading, 5)
  }
  private var rulesSheet: some View {
    VStack(spacing: 20) {
      Text("亲密度提升攻略").font(.system(size: 20, weight: .bold)).padding(.top, 40)
      ScrollView { VStack(alignment: .leading, spacing: 10) { ForEach(Array(rules["up_level"].list.enumerated()), id: \.offset) { _, rule in VStack(alignment: .leading, spacing: 16) { HStack(spacing: 3) { QQArtwork(name: "lv_ico_point01").frame(width: 7, height: 7); Text(rule["title"].text).font(.system(size: 16, weight: .bold)) }; QQServiceRichText(value: rule["content"].text).font(.system(size: 13)).foregroundStyle(.gray).lineSpacing(6) }.frame(maxWidth: .infinity, alignment: .leading).padding(20).background(.white, in: RoundedRectangle(cornerRadius: 20)) } }.padding(.horizontal, 20) }
    }.background(Color(red: 0.96, green: 0.985, blue: 1)).overlay(alignment: .topTrailing) { Button { showingRules = false } label: { QQArtwork(name: "pop_ico_close").frame(width: 32, height: 32) }.padding(20).accessibilityLabel("关闭") }.presentationDetents([.fraction(0.72)]).presentationCornerRadius(30)
  }
  private var boostOverlay: some View {
    ZStack {
      Color.black.opacity(0.7).ignoresSafeArea().onTapGesture { showingBoost = false }
      VStack(spacing: 16) {
        Spacer()
        QQArtwork(name: "pop_double_bg").frame(width: 250, height: 270)
        QQServiceRichText(value: rules["double_card"]["tips"].text.isEmpty ? rules["double_card"]["intro"].text : rules["double_card"]["tips"].text, emphasisColor: Color(red: 0.8, green: 0.6, blue: 1)).font(.system(size: 13)).foregroundStyle(.white).lineSpacing(10).multilineTextAlignment(.center)
        Button { confirmingBoost = true } label: { HStack(spacing: 5) { QQArtwork(name: "chatset_ico_diamond").frame(width: 16, height: 16); Text(rules["double_card"]["buy"].text + " 去购买").font(.system(size: 16, weight: .bold)) }.frame(width: 200, height: 52).background(LinearGradient(colors: [Color(red: 0.75, green: 0.6, blue: 1), Color(red: 1, green: 0.85, blue: 0.96), Color(red: 0.55, green: 0.5, blue: 0.9)], startPoint: .leading, endPoint: .trailing), in: Capsule()) }.disabled(buying || unknown || rules["double_card"]["buy"].text.isEmpty)
        Spacer()
        Button { showingBoost = false } label: { QQArtwork(name: "pop_ico_close").frame(width: 32, height: 32) }.padding(.bottom, 110).accessibilityLabel("关闭购买说明")
      }.padding(.horizontal, 20)
    }
  }
  private func buyBoost() async {
    guard !buying, !unknown else { return }
    buying = true; UserDefaults.standard.set(true, forKey: pendingKey)
    defer { buying = false }
    do {
      _ = try await store.api.request("role/buyDoubleCard", method: "POST", parameters: ["role_id": role.id])
      UserDefaults.standard.removeObject(forKey: pendingKey); showingBoost = false
      await store.refreshUser(); info = try await store.api.request("role/getMemberRole", parameters: ["role_id": role.id])
    } catch let failure as QQAPIError {
      if case .service(let code, _) = failure, code > 0 { UserDefaults.standard.removeObject(forKey: pendingKey) } else { unknown = true }
      error = failure.localizedDescription; showingBoost = false
    } catch { unknown = true; self.error = "购买结果尚未确认，请先核实钻石明细。"; showingBoost = false }
  }
}

/// Service copy uses simple HTML emphasis. Render that text without a web view.
struct QQServiceRichText: View {
  let value: String
  var emphasisColor: Color = .black
  var body: some View { text }
  private var text: Text {
    let normalized = value.replacingOccurrences(of: "<br\\s*/?>", with: "\n", options: .regularExpression).replacingOccurrences(of: "&nbsp;", with: " ").replacingOccurrences(of: "&amp;", with: "&")
    guard let regex = try? NSRegularExpression(pattern: "<(?:b|strong|font)[^>]*>(.*?)</(?:b|strong|font)>", options: [.dotMatchesLineSeparators]) else { return Text(normalized) }
    let source = normalized as NSString
    var result = Text(""); var cursor = 0
    for match in regex.matches(in: normalized, range: NSRange(location: 0, length: source.length)) {
      result = result + markdown(source.substring(with: NSRange(location: cursor, length: match.range.location - cursor)).replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression))
      result = result + Text(source.substring(with: match.range(at: 1)).replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)).bold().foregroundColor(emphasisColor)
      cursor = match.range.location + match.range.length
    }
    return result + markdown(source.substring(from: cursor).replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression))
  }
  private func markdown(_ value: String) -> Text {
    let parts = value.components(separatedBy: "**")
    return parts.enumerated().reduce(Text("")) { result, element in result + (element.offset.isMultiple(of: 2) ? Text(element.element) : Text(element.element).bold().foregroundColor(emphasisColor)) }
  }
}

private struct QQTimelineLine: Shape {
  func path(in rect: CGRect) -> Path { Path { $0.move(to: CGPoint(x: rect.midX, y: 0)); $0.addLine(to: CGPoint(x: rect.midX, y: rect.maxY)) } }
}
