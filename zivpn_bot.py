import telebot, subprocess, os
from telebot import types
from datetime import datetime, timedelta

# === CONFIGURATION ===
TOKEN = '8509037286:AAEMao-IFVx0V1VK2xbDEILMNO7plLuK5hE'
ADMIN_ID = 1358908223 # ISI ID TELEGRAM ANDA
CONF = "/etc/zivpn/config.json"
DB = "/etc/zivpn/accounts.db"

bot = telebot.TeleBot(TOKEN)

def run_cmd(cmd):
    return subprocess.getoutput(cmd)

@bot.message_handler(commands=['start', 'menu'])
def menu(m):
    if m.from_user.id != ADMIN_ID: return
    markup = types.ReplyKeyboardMarkup(row_width=2, resize_keyboard=True)
    markup.add('➕ Create UDP', '⏳ Trial UDP', '📜 List Akun', '❌ Delete UDP', '📊 Status')
    bot.send_message(m.chat.id, "🚀 *ZiVPN ADMIN PANEL*", reply_markup=markup, parse_mode='Markdown')

@bot.message_handler(func=lambda m: True)
def handle_menu(m):
    if m.from_user.id != ADMIN_ID: return
    
    if m.text == '➕ Create UDP':
        msg = bot.reply_to(m, "Format: `user hari` (Contoh: `premium 30`)")
        bot.register_next_step_handler(msg, lambda msg: process_vpn(msg, False))
    elif m.text == '⏳ Trial UDP':
        process_vpn(m, True)
    elif m.text == '📜 List Akun':
        if os.path.exists(DB):
            data = run_cmd(f"cat {DB}")
            bot.send_message(m.chat.id, f"📜 *LIST AKUN:*\n```\n{data if data else 'Kosong'}\n```", parse_mode='MarkdownV2')
    elif m.text == '❌ Delete UDP':
        msg = bot.reply_to(m, "Masukkan Password yang ingin dihapus:")
        bot.register_next_step_handler(msg, delete_vpn)
    elif m.text == '📊 Status':
        stat = run_cmd("systemctl is-active zivpn")
        bot.reply_to(m, f"📊 Service Status: `{stat.upper()}`", parse_mode='Markdown')

def process_vpn(m, is_trial):
    try:
        user = "trial" + run_cmd("date +%S") if is_trial else m.text.split()[0]
        days = 1 if is_trial else int(m.text.split()[1])
        exp = (datetime.now() + timedelta(days=days)).strftime("%Y-%m-%d")
        
        # Inject ke config.json
        run_cmd(f"jq '.config += [\"{user}\"]' {CONF} > tmp.json && mv tmp.json {CONF}")
        with open(DB, "a") as f: f.write(f"{user}|{exp}\n")
        os.system("systemctl restart zivpn")
        
        host = run_cmd("cat /etc/zivpn/domain") if os.path.exists("/etc/zivpn/domain") else run_cmd("curl -s ifconfig.me")
        
        res = (
            f"```\n"
            f"══════════════════════════════\n"
            f"    ZIVPN UDP PRO SELLER      \n"
            f"══════════════════════════════\n"
            f" Host/IP  : {host}\n"
            f" Password : {user}\n"
            f" Port UDP : 6000-19999\n"
            f" Expired  : {exp} ({days} Hari)\n"
            f"══════════════════════════════\n"
            f" Format: {host}|{user}|{exp}\n"
            f"══════════════════════════════\n"
            f"```"
        )
        bot.send_message(m.chat.id, res, parse_mode='MarkdownV2')
    except: bot.send_message(m.chat.id, "❌ Error! Format salah.")

def delete_vpn(m):
    user = m.text
    run_cmd(f"jq '.config -= [\"{user}\"]' {CONF} > tmp.json && mv tmp.json {CONF}")
    run_cmd(f"sed -i '/^{user}|/d' {DB}")
    os.system("systemctl restart zivpn")
    bot.reply_to(m, f"✅ `{user}` Berhasil Dihapus!")

bot.polling()
