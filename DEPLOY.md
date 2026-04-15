# 部署指南

## 环境要求

- Go 1.22+
- Linux VPS（推荐 Ubuntu/Debian）

## 1. 克隆项目到服务器

```bash
git clone https://github.com/whwh1233/gatus.git /opt/gatus
cd /opt/gatus
```

## 2. 编译

```bash
make install
```

## 3. 配置环境变量

```bash
cp .env.example .env
vim .env
```

填入实际的 API Key：

```
CLAUDE_CODEMAX_KEY=sk-xxx
GPT54_KEY=sk-xxx
```

## 4. 启动

### 直接运行（测试用）

```bash
./start.sh
```

### Systemd 服务（推荐）

```bash
sudo cp gatus.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now gatus
```

常用命令：

```bash
sudo systemctl status gatus    # 查看状态
sudo systemctl restart gatus   # 重启
sudo journalctl -u gatus -f    # 查看日志
```

## 5. 访问

浏览器打开 `http://<服务器IP>:8080`

## 更新部署

```bash
cd /opt/gatus
git pull
make install
sudo systemctl restart gatus
```
