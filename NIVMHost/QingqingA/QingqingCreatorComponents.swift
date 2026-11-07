import SwiftUI

struct QQCreatorNoticeView: View {
  @Environment(\.dismiss) private var dismiss
  @AppStorage("qingqing.creator.hideNotice") private var hideNotice = false
  var body: some View {
    VStack(spacing: 20) {
      Text("创作者须知").font(.system(size: 16, weight: .bold)).padding(.top, 40)
      VStack(alignment: .leading, spacing: 6) {
        Text("请各位创作者遵守平台约定：").font(.system(size: 13)).foregroundStyle(.gray).padding(.bottom, 4)
        ForEach(["不能涉及血腥暴力", "不能涉及未成年角色不适场景", "不能涉及现实人物/组织", "不得抄袭、剽窃他人作品", "请尊重原创"], id: \.self) { rule in
          HStack(spacing: 10) { Image(systemName: rule == "请尊重原创" ? "checkmark.square.fill" : "xmark.square.fill").foregroundStyle(rule == "请尊重原创" ? .green : .red); Text(rule).font(.system(size: 14)); Spacer(minLength: 0) }.padding(.horizontal, 16).frame(height: 44).background(rule == "请尊重原创" ? .green.opacity(0.06) : .red.opacity(0.05), in: RoundedRectangle(cornerRadius: 15))
        }
        Text("以上内容如审核发现，会直接删除或下架处理").font(.system(size: 13)).foregroundStyle(.gray).padding(.top, 4)
      }.padding(16).padding(.vertical, 4).background(.white, in: RoundedRectangle(cornerRadius: 22)).padding(.horizontal, 20)
      QQPrimaryButton(title: "我知道了") { dismiss() }.padding(.horizontal, 20)
      Button("不再提醒") { hideNotice = true; dismiss() }.font(.system(size: 14)).foregroundStyle(.gray)
      Spacer(minLength: 10)
    }.background(QQStyle.background).overlay(alignment: .topTrailing) { Button { dismiss() } label: { Image(systemName: "xmark").font(.system(size: 14, weight: .bold)).foregroundStyle(.gray.opacity(0.5)).frame(width: 24, height: 24).background(.white, in: Circle()) }.padding(20) }
  }
}

struct QQTagSelectionView: View {
  @Environment(\.dismiss) private var dismiss
  @Binding var selection: String
  let configuration: QQValue
  @State private var draft: [String] = []
  @State private var custom = false
  @State private var customText = ""
  var body: some View {
    VStack(spacing: 0) {
      HStack {
        Button { dismiss() } label: { Image(systemName: "xmark").font(.system(size: 22)) }.frame(width: 32)
        Spacer()
        Text("添加标签(\(draft.count)/5)").font(.system(size: 16, weight: .bold))
        Spacer()
        Button("确定") { selection = draft.joined(separator: ","); dismiss() }.font(.system(size: 12, weight: .bold)).frame(width: 54, height: 28).background(QQStyle.gradient, in: Capsule())
      }.padding(.horizontal, 20).padding(.top, 30).padding(.bottom, 10)
      ScrollView {
        VStack(alignment: .leading, spacing: 20) {
          HStack { Button { customText = ""; custom = true } label: { Text("＋自定义").font(.system(size: 14, weight: .bold)).padding(.horizontal, 12).frame(height: 36).overlay { Capsule().stroke(Color(white: 0.78), style: StrokeStyle(lineWidth: 2, dash: [4, 4])) } }; Spacer(); if !draft.isEmpty { Text("已选 \(draft.count)/5").font(.system(size: 12)).foregroundStyle(.gray) } }.padding(.top, 20)
          tagGroup("背景", options: configuration["tag"]["bj"].list.map(\.text))
          tagGroup("性格", options: configuration["tag"]["xg"].list.map(\.text))
        }.padding(.horizontal, 20).padding(.bottom, 20)
      }
    }.background(QQStyle.background).toolbar(.hidden, for: .navigationBar).onAppear { draft = selection.components(separatedBy: ",").filter { !$0.isEmpty } }
      .overlay { if custom { customDialog } }
  }
  private func tagGroup(_ title: String, options: [String]) -> some View {
    VStack(alignment: .leading, spacing: 16) {
      Text(title).font(.system(size: 16, weight: .bold))
      LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 7), count: 4), spacing: 8) {
        ForEach(options, id: \.self) { option in Button { toggle(option) } label: { Text(option).font(.system(size: 13)).foregroundStyle(draft.contains(option) ? .cyan : Color(white: 0.6)).frame(maxWidth: .infinity).frame(height: 38).background(Color(white: 0.96), in: Capsule()).overlay { Capsule().stroke(draft.contains(option) ? .cyan : .clear, lineWidth: 1) } } }
      }
    }.padding(15).padding(.vertical, 5).background(.white, in: RoundedRectangle(cornerRadius: 22))
  }
  private func toggle(_ value: String) { if draft.contains(value) { draft.removeAll { $0 == value } } else if draft.count < 5 { draft.append(value) } }
  private var customDialog: some View {
    ZStack {
      Color.black.opacity(0.35).ignoresSafeArea()
      VStack(spacing: 25) {
        HStack { Spacer(); Text("自定义标签").font(.system(size: 16, weight: .bold)); Spacer() }.overlay(alignment: .trailing) { Text("\(customText.count)/5").font(.system(size: 14)).foregroundStyle(.gray.opacity(0.4)) }
        TextField("请输入自定义标签", text: $customText).font(.system(size: 15)).padding(.horizontal, 16).frame(height: 48).background(Color(white: 0.96), in: RoundedRectangle(cornerRadius: 12)).onChange(of: customText) { _, value in customText = String(value.filter { !",，\n".contains($0) }.prefix(5)) }
        HStack(spacing: 8) {
          Button("取消") { custom = false }.frame(maxWidth: .infinity).frame(height: 42).background(Color(white: 0.96), in: RoundedRectangle(cornerRadius: 10))
          Button("提交") { let value = customText.trimmingCharacters(in: .whitespaces); guard !value.isEmpty, draft.count < 5 || draft.contains(value) else { return }; if !draft.contains(value) { draft.append(value) }; custom = false }.frame(maxWidth: .infinity).frame(height: 42).background(QQStyle.gradient, in: RoundedRectangle(cornerRadius: 10)).disabled(customText.trimmingCharacters(in: .whitespaces).isEmpty || draft.count >= 5)
        }.font(.system(size: 14, weight: .bold))
      }.padding(.horizontal, 20).padding(.vertical, 30).frame(width: 280).background(.white, in: RoundedRectangle(cornerRadius: 30))
    }
  }
}
