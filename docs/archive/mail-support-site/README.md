# 历史临时邮箱支持站点（已归档）

该目录仅保存已移除功能的历史支持页，不属于当前爱锦 AI 工程的活动站点，不能作为当前 AI 服务的隐私声明。本次没有部署或修改线上站点。

# TempMail 支持网站

静态支持页和隐私政策。公开目录仅 `public/`。

- https://tempmail.9355.my/support
- https://tempmail.9355.my/privacy

部署：`npx wrangler deploy`。账号 74dcb623526e1925a35e0991a0940f16，Worker tempmail-support。

隐私内容根据 TempMailAPIClient.swift、TempMailDetailView.swift 及 temp_email_service.go 核对；邮箱删除为软删除，不承诺自动定时销毁。
