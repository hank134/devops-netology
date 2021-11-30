5. Проц 2 цп
 ОЗУ 1 ГБ
HDD 64 ГБ
6. поправить конфиг
Vagrant.configure("2") do |config|
 	config.vm.box = "bento/ubuntu-20.04"
 		config.vm.provider "virtualbox" do |vb|
     		vb.memory = "2024"
        end
end

8. histFilesize максиамальнео число стро содержащиеся в файл истории 727 строка

не записывает в историю лишние пробелы и дуликаты комнд 837 строка
9. гупповая комнада, когда нужно сделать одну и ту же кманду для группы значений 257
10. touch {1..100000}, touch {1..300000} команда превышает максимальную разрешенную длинну аргумента
11. проверяет сущетсвет ли папка tmp в задннйо диркектории
12. 
vagrant@vagrant:~$ mkdir -p /tmp/new_path_directory/
vagrant@vagrant:~$ cp /usr/bin/bash /tmp/new_path_directory/
vagrant@vagrant:/$ PATH=/tmp/new_path_directory/:$PATH
vagrant@vagrant:/$ type -a bash
bash is /tmp/new_path_directory/bash
bash is /usr/bin/bash
bash is /bin/bash
13. at позволяет запланировать выолнение  команды в определенное время
batch позволяет запланировать задание в определенное время и выполняется только если загрузка системы не более чем 1,5, иначе ждет очереди.
