.PHONY: vault-encrypt vault-decrypt vault-view vault-edit vault-run

#Vault команды
vault-encrypt:
	@ansible-vault encrypt vault/gold.yml

vault-decrypt:
	@ansible-vault decrypt vault/gold.yml

vault-view:
	@ansible-vault view vault/gold.yml

vault-edit:
	@ansible-vault edit vault/gold.yml

vault-setup:
	@echo "Пароль от хранилища:" && \
	read -s VAULT_PASS && \
	echo "$$VAULT_PASS" > .vault_pass.txt && \
	chmod 600 .vault_pass.txt && \
	echo "Пароль положили в .vault_pass.txt"

vault-run:
	@if [ -f .vault_pass.txt ]; then \
		ansible-playbook site.yml -i inventory/hosts.ini --vault-password-file .vault_pass.txt; \
	else \
		ansible-playbook site.yml -i inventory/hosts.ini --ask-vault-pass; \
	fi

vault-check:
	@if [ -f .vault_pass.txt ]; then \
		ansible-playbook --syntax-check site.yml -i inventory/hosts.ini --vault-password-file .vault_pass.txt; \
	else \
		ansible-playbook --syntax-check site.yml -i inventory/hosts.ini --ask-vault-pass; \
	fi

check: inventory syntax vault-check
