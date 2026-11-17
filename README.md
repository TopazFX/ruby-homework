# Контрольна робота з Ruby, варіант 3

Модуль Inventory читає список товарів з JSON, перевіряє його і рахує загальну вартість.
Скрипт bin/total.rb друкує суму в гривнях.

Харина Сергій, КС31

## Запуск

```
ruby bin/total.rb
ruby bin/total.rb data/bad_quantity.json
ruby bin/total.rb data/bad_syntax.json
ruby bin/total.rb data/nope.json
```

Для data/products.json виводить `262.50 грн`.
Код виходу: 2 при помилці в даних, 3 якщо файл не знайдено (у PowerShell дивитись `echo $LASTEXITCODE`).
