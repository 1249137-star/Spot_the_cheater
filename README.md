# Spot the Cheater

> **Сатирический 2D менеджмент-симулятор преподавателя против списывающих студентов на Godot 4.**

---

##  Команда и зоны ответственности

| Участник | Роль | Основная зона файлов | За что отвечает |
| :--- | :--- | :--- | :--- |
| **Вадим М.** | **Архитектура сцен и каркас** | `scenes/main_game.tscn`, `scenes/main_menu.tscn`, `scripts/core/` | Меню, переходы уровней, сборка сетки 15 камер, таймер пары |
| **Арсений Т.** | **Логика студентов ** | `scripts/students/student_ai.gd`, `variant_manager.gd` | Поведение студентов, шансы списывания, реакция на преподавателя |
| **Ульяна Т.** | **Визуал, ассеты и звук** | `assets/`, `scenes/student_feed.tscn` | Оформление камер CCTV, спрайты, шейдеры помех, звуки |
| **Михаил П.** | **Логика преподавателя** | `scripts/teacher/teacher_panel.gd`, `scenes/teacher_panel.tscn` | Санкции (изъятие, овайп), способности («Грозный взгляд»), хаос |

---

## 📁 Структура проекта

```text
res://
├── assets/                  
│   ├── audio/               
│   ├── sprites/            
│   └── ui/                  
├── docs/                   
├── scenes/                  
│   ├── main_menu.tscn       
│   ├── main_game.tscn       
│   ├── student_feed.tscn   
│   └── teacher_panel.tscn   
└── scripts/                 
    ├── core/                
    ├── students/            
    └── teacher/            
```

---

