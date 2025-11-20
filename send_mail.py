#!/usr/bin/env python3

import smtplib
import sys
import os
from email.message import EmailMessage
from email.utils import make_msgid

# Configuração

SMTP_SERVER = "smtp.gmail.com"
SMTP_PORT = 587                  # 465 para SSL, 587 para STARTTLS
SMTP_USER = "Seu email"
SMTP_PASS = "senha de app"   # senha de app, não a normal

SUBJECT = "Seu documento"
BODY_TEXT = "Olá,\n\nSegue o seu documento em anexo.\n\nAtenciosamente."

# Função de envio do email

def enviar_email(destinatario, arquivo_anexo):
    if not os.path.isfile(arquivo_anexo):
        print(f"ERRO: arquivo {arquivo_anexo} não existe.")
        return False

    msg = EmailMessage()
    msg["Subject"] = SUBJECT
    msg["From"] = SMTP_USER
    msg["To"] = destinatario
    msg.set_content(BODY_TEXT)

    # Anexar PDF
    with open(arquivo_anexo, "rb") as f:
        data = f.read()
        msg.add_attachment(data, maintype="application", subtype="pdf", filename=os.path.basename(arquivo_anexo))

    try:
        with smtplib.SMTP(SMTP_SERVER, SMTP_PORT) as smtp:
            smtp.starttls()
            smtp.login(SMTP_USER, SMTP_PASS)
            smtp.send_message(msg)
        print(f"[OK] Email enviado para {destinatario}")
        return True
    except Exception as e:
        print(f"[FALHA] Não foi possível enviar para {destinatario}: {e}")
        return False

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Uso: python send_mail.py <destinatario> <arquivo_anexo>")
        sys.exit(1)

    destinatario = sys.argv[1]
    arquivo_anexo = sys.argv[2]
    enviar_email(destinatario, arquivo_anexo)