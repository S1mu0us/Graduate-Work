VAULT_FILE="vault/gold.yml"
VAULT_PASS_FILE=".vault_pass.txt"

case "$1" in
    encrypt)
        ansible-vault encrypt "$VAULT_FILE"
        ;;
    decrypt)
        ansible-vault decrypt "$VAULT_FILE"
        ;;
    view)
        ansible-vault view "$VAULT_FILE"
        ;;
    edit)
        ansible-vault edit "$VAULT_FILE"
        ;;
    create)
        ansible-vault create "$VAULT_FILE"
        ;;
    rekey)
        ansible-vault rekey "$VAULT_FILE"
        ;;
    setup)
        echo "Сборка сундука с кодом для хранилища..."
        read -sp "Пароль от хранилища: " VAULT_PASS
        echo
        echo "$VAULT_PASS" > "$VAULT_PASS_FILE"
        chmod 600 "$VAULT_PASS_FILE"
        echo "Пароль положили в $VAULT_PASS_FILE"
        ;;
    run)
        if [ -f "$VAULT_PASS_FILE" ]; then
            ansible-playbook site.yml -i inventory/hosts.ini --vault-password-file "$VAULT_PASS_FILE"
        else
            ansible-playbook site.yml -i inventory/hosts.ini --ask-vault-pass
        fi
        ;;
    check)
        ansible-playbook --syntax-check site.yml -i inventory/hosts.ini --ask-vault-pass
        ;;
    *)
        echo "Использование: $0 {encrypt|decrypt|view|edit|create|rekey|setup|run|check}"
        echo ""
        echo "  encrypt   - Зашифровать файл с секретами"
        echo "  decrypt   - Расшифровать файл с секретами"
        echo "  view      - Просмотреть зашифрованный файл"
        echo "  edit      - Редактировать зашифрованный файл"
        echo "  create    - Создать новый зашифрованный файл"
        echo "  rekey     - Сменить пароль шифрования"
        echo "  setup     - Настроить файл с паролем"
        echo "  run       - Запустить playbook с vault"
        echo "  check     - Проверить синтаксис с vault"
        exit 1
        ;;
esac
