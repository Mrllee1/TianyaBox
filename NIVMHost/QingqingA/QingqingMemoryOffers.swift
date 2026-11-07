import SwiftUI

/// Original memory offer layouts. All commercial text, prices and identifiers
/// come from the corresponding API; an unavailable catalog stays unavailable.
struct QQMemoryOffersContent: View {
  let offers: QQMemoryOffers
  @Binding var selected: QQRecord?
  @Binding var selectedWay: QQRecord?
  let loading: Bool
  let canPurchase: Bool
  let buy: () -> Void
  private let purple = Color(red: 129.0/255, green: 109.0/255, blue: 1)
  private var capacity: Bool { offers.kind == .capacity }
  private var info: QQValue { capacity ? offers.information : offers.payload }
  var body: some View {
    VStack(spacing: 0) {
      QQArtwork(name: capacity ? "amount_pic_title" : "memory_pic_title")
        .frame(width: capacity ? 224 : 249, height: capacity ? 66 : 60).padding(.top, capacity ? 18 : 20)
      if capacity { explanation.padding(.top, 30) }
      if loading { ProgressView().frame(maxWidth: .infinity).padding(50) }
      else if offers.owned { unlocked.padding(.top, 20) }
      else {
        if offers.packages.isEmpty {
          Text("当前暂无可购买的套餐").font(.system(size: 14)).foregroundStyle(.gray).padding(.vertical, 40)
        } else if capacity {
          HStack(alignment: .top, spacing: 12) {
            ForEach(Array(offers.packages.prefix(2).enumerated()), id: \.element.id) { index, package in
              capacityCard(package, orange: index == 1 || offers.packages.count == 1)
            }
          }.padding(.top, 20)
        } else {
          VStack(spacing: 12) { ForEach(offers.packages) { package in unlockCard(package) } }.padding(.top, 22)
        }
        if !offers.packages.isEmpty {
          HStack(spacing: 0) { ForEach(offers.payWays) { way in
            Button { selectedWay = way } label: {
              HStack(spacing: 7) {
                Image(systemName: selectedWay?.id == way.id ? "checkmark.circle.fill" : "circle").foregroundStyle(selectedWay?.id == way.id ? purple : .gray.opacity(0.3))
                Text(way.name).font(.system(size: 13)).lineLimit(1)
              }.frame(maxWidth: .infinity).frame(height: 50)
            }.buttonStyle(.plain)
          } }.background(.white, in: RoundedRectangle(cornerRadius: capacity ? 8 : 15)).padding(.top, capacity ? 25 : 16)
          Button(action: buy) {
            Text(info["buy_btn_text"].text.isEmpty ? (capacity ? "立即购买" : "立即解锁") : info["buy_btn_text"].text)
              .font(.system(size: 16, weight: .bold)).foregroundStyle(capacity ? Color(red: 236.0/255, green: 50.0/255, blue: 8.0/255) : .white)
              .frame(maxWidth: .infinity).frame(height: capacity ? 56 : 50)
              .background(LinearGradient(colors: capacity ? [Color(red: 254.0/255, green: 245.0/255, blue: 218.0/255), Color(red: 254.0/255, green: 206.0/255, blue: 126.0/255)] : [Color(red: 1, green: 144.0/255, blue: 89.0/255), Color(red: 1, green: 108.0/255, blue: 50.0/255)], startPoint: .leading, endPoint: .trailing), in: Capsule())
          }.disabled(!canPurchase).opacity(canPurchase ? 1 : 0.45).padding(.horizontal, capacity ? 0 : 10).padding(.top, capacity ? 25 : 20)
        }
      }
    }.padding(.horizontal, 20).padding(.bottom, 37)
  }
  private var explanation: some View {
    VStack(spacing: 10) {
      HStack(spacing: 4) {
        QQArtwork(name: "amount_ico_heart").frame(width: 16, height: 16)
        Text(info["what_title"].text).font(.system(size: 14, weight: .bold)).foregroundStyle(purple)
        QQArtwork(name: "amount_ico_heart").frame(width: 16, height: 16)
      }.padding(.horizontal, 12).padding(.vertical, 5).background(Color(red: 246.0/255, green: 244.0/255, blue: 1), in: Capsule()).overlay { Capsule().stroke(purple.opacity(0.25), lineWidth: 1) }
      Text(info["desc_list"].list.map(\.text).joined(separator: "\n")).font(.system(size: 11)).lineSpacing(5).multilineTextAlignment(.center).foregroundStyle(Color(white: 101.0/255))
    }.padding(.horizontal, 19).padding(.vertical, 20).frame(maxWidth: .infinity).background(.white, in: RoundedRectangle(cornerRadius: 22)).overlay { RoundedRectangle(cornerRadius: 22).stroke(Color(red: 246.0/255, green: 244.0/255, blue: 1), lineWidth: 2) }
  }
  private var unlocked: some View {
    VStack(spacing: 0) {
      HStack(spacing: 4) {
        QQArtwork(name: "amount_ico_left").frame(width: 9, height: 9)
        Text(info["unlock_title"].text.isEmpty ? "已解锁最高记忆条数" : info["unlock_title"].text).font(.system(size: 14)).foregroundStyle(Color(red: 231.0/255, green: 167.0/255, blue: 59.0/255))
        QQArtwork(name: "amount_ico_right").frame(width: 9, height: 9)
      }
      Text(info["unlock_sub_title"].text.isEmpty ? "更多故事，都能被好好留住" : info["unlock_sub_title"].text).font(.system(size: 11)).foregroundStyle(.gray).padding(.top, 4)
      ForEach(Array(info["features"].records.enumerated()), id: \.offset) { index, feature in
        HStack(spacing: 10) {
          QQArtwork(name: "amount_ico_advantage0\(min(index + 1, 4))").frame(width: 25, height: 25)
          VStack(alignment: .leading, spacing: 5) { Text(feature.name).font(.system(size: 13, weight: .medium)); Text(feature["desc"]).font(.system(size: 11)).foregroundStyle(.gray) }
          Spacer(minLength: 0)
        }.padding(.top, 17)
      }
    }.padding(20).frame(maxWidth: .infinity).background(.white, in: RoundedRectangle(cornerRadius: 22)).overlay { RoundedRectangle(cornerRadius: 22).stroke(purple.opacity(0.15), lineWidth: 2) }
  }
  private func capacityCard(_ package: QQRecord, orange: Bool) -> some View {
    let chosen = selected?.id == package.id
    let ink = orange ? Color(red: 1, green: 117.0/255, blue: 32.0/255) : Color(red: 237.0/255, green: 26.0/255, blue: 188.0/255)
    return Button { selected = package } label: {
      VStack(spacing: 9) {
        HStack(spacing: 3) {
          QQArtwork(name: orange ? "amount_pic_orange" : "amount_pic_pink").frame(width: 17, height: 14)
          Text(package.name).font(.system(size: 17, weight: .bold)).lineLimit(1).minimumScaleFactor(0.7)
          QQArtwork(name: orange ? "amount_pic_orange" : "amount_pic_pink").frame(width: 17, height: 14).rotationEffect(.degrees(180))
        }.foregroundStyle(ink)
        VStack(alignment: .leading, spacing: 7) { ForEach(Array(package.value["tips"].list.enumerated()), id: \.offset) { _, tip in HStack(alignment: .top, spacing: 4) { QQArtwork(name: "amount_pic_list").frame(width: 10, height: 13); Text(tip.text).font(.system(size: 11)).lineSpacing(3).fixedSize(horizontal: false, vertical: true) } } }.frame(maxWidth: .infinity, alignment: .leading)
        HStack(alignment: .firstTextBaseline, spacing: 1) { Text("¥").font(.system(size: 12)); Text(package["price"]).font(.system(size: 20, weight: .bold, design: .rounded)) }.foregroundStyle(ink).frame(maxWidth: 116).frame(height: 30).background(ink.opacity(0.12), in: RoundedRectangle(cornerRadius: 8)).padding(.top, 6)
      }.padding(.horizontal, 12).padding(.top, 14).padding(.bottom, 30).frame(maxWidth: .infinity)
        .background(orange && chosen ? Color(red: 1, green: 245.0/255, blue: 224.0/255) : .white, in: RoundedRectangle(cornerRadius: 22))
        .overlay { RoundedRectangle(cornerRadius: 22).stroke(ink.opacity(chosen ? 0.8 : 0.3), lineWidth: chosen ? 3 : 2) }
        .overlay(alignment: .topTrailing) { if !package["tag"].isEmpty { Text(package["tag"]).font(.system(size: 9)).foregroundStyle(.white).padding(.horizontal, 7).padding(.vertical, 3).background(ink, in: UnevenRoundedRectangle(topLeadingRadius: 9, bottomLeadingRadius: 9, topTrailingRadius: 22)) } }
        .overlay(alignment: .bottomTrailing) { if chosen { QQArtwork(name: "amount_ico_selected").frame(width: 24, height: 24) } }
    }.buttonStyle(.plain)
  }
  private func unlockCard(_ package: QQRecord) -> some View {
    let chosen = selected?.id == package.id
    return Button { selected = package } label: {
      HStack(spacing: 12) {
        QQArtwork(name: package["is_all"] == "1" ? "memory_ico_total" : "memory_ico_single").frame(width: 36, height: 36)
        VStack(alignment: .leading, spacing: 7) { HStack { Text(package.name).font(.system(size: 15)); if !package["tag"].isEmpty { Text(package["tag"]).font(.system(size: 10)).foregroundStyle(.orange) } }; Text(package["desc"]).font(.system(size: 12)).foregroundStyle(.gray) }
        Spacer(minLength: 0)
        Text("¥" + package["price"]).font(.system(size: 25, weight: .bold, design: .rounded)).foregroundStyle(Color(red: 236.0/255, green: 50.0/255, blue: 8.0/255))
      }.padding(.horizontal, 17).padding(.vertical, 19).frame(minHeight: 80).background(chosen ? Color(red: 1, green: 0.94, blue: 0.83) : .white, in: RoundedRectangle(cornerRadius: 22)).overlay { RoundedRectangle(cornerRadius: 22).stroke(chosen ? .orange.opacity(0.8) : .clear, lineWidth: 2) }
    }.buttonStyle(.plain)
  }
}
