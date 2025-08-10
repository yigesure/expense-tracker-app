// 应用状态管理
class ExpenseTracker {
    constructor() {
        this.transactions = this.loadTransactions();
        this.currentBalance = this.calculateBalance();
        this.init();
    }

    init() {
        this.bindEvents();
        this.renderTransactions();
        this.updateBalance();
        this.setCurrentDate();
    }

    // 事件绑定
    bindEvents() {
        // 底部导航
        document.querySelectorAll('.nav-item').forEach(item => {
            item.addEventListener('click', (e) => {
                this.switchPage(e.currentTarget.dataset.page);
            });
        });

        // 快速操作按钮
        document.getElementById('addIncomeBtn').addEventListener('click', () => {
            this.openModal('income');
        });
        
        document.getElementById('addExpenseBtn').addEventListener('click', () => {
            this.openModal('expense');
        });

        // 浮动按钮
        document.getElementById('addTransactionFab').addEventListener('click', () => {
            this.openModal('expense');
        });

        // 模态框控制
        document.getElementById('closeModal').addEventListener('click', () => {
            this.closeModal();
        });

        document.getElementById('cancelBtn').addEventListener('click', () => {
            this.closeModal();
        });

        // 表单提交
        document.getElementById('transactionForm').addEventListener('submit', (e) => {
            e.preventDefault();
            this.addTransaction();
        });

        // 类型选择器
        document.querySelectorAll('.type-btn').forEach(btn => {
            btn.addEventListener('click', (e) => {
                document.querySelectorAll('.type-btn').forEach(b => b.classList.remove('active'));
                e.target.classList.add('active');
            });
        });

        // 余额可见性切换
        document.getElementById('balanceToggle').addEventListener('click', () => {
            this.toggleBalanceVisibility();
        });

        // 模态框背景点击关闭
        document.getElementById('addTransactionModal').addEventListener('click', (e) => {
            if (e.target === e.currentTarget) {
                this.closeModal();
            }
        });
    }

    // 页面切换
    switchPage(page) {
        document.querySelectorAll('.nav-item').forEach(item => {
            item.classList.remove('active');
        });
        document.querySelector(`[data-page="${page}"]`).classList.add('active');
        
        // 这里可以添加页面切换逻辑
        console.log(`切换到页面: ${page}`);
    }

    // 打开模态框
    openModal(type = 'expense') {
        const modal = document.getElementById('addTransactionModal');
        modal.classList.add('show');
        
        // 设置默认类型
        document.querySelectorAll('.type-btn').forEach(btn => {
            btn.classList.remove('active');
        });
        document.querySelector(`[data-type="${type}"]`).classList.add('active');
        
        // 清空表单
        document.getElementById('transactionForm').reset();
        this.setCurrentDate();
    }

    // 关闭模态框
    closeModal() {
        const modal = document.getElementById('addTransactionModal');
        modal.classList.remove('show');
    }

    // 设置当前日期
    setCurrentDate() {
        const today = new Date().toISOString().split('T')[0];
        document.getElementById('date').value = today;
    }

    // 添加交易
    addTransaction() {
        const form = document.getElementById('transactionForm');
        const formData = new FormData(form);
        
        const transaction = {
            id: Date.now(),
            type: document.querySelector('.type-btn.active').dataset.type,
            amount: parseFloat(document.getElementById('amount').value),
            category: document.getElementById('category').value,
            description: document.getElementById('description').value || '无备注',
            date: document.getElementById('date').value,
            timestamp: new Date().toISOString()
        };

        this.transactions.unshift(transaction);
        this.saveTransactions();
        this.renderTransactions();
        this.updateBalance();
        this.closeModal();
        
        // 显示成功提示
        this.showToast('交易添加成功！');
    }

    // 渲染交易列表
    renderTransactions() {
        const container = document.getElementById('transactionList');
        const recentTransactions = this.transactions.slice(0, 5);
        
        if (recentTransactions.length === 0) {
            container.innerHTML = `
                <div style="text-align: center; padding: 40px 20px; color: #6b7280;">
                    <span class="material-icons" style="font-size: 48px; margin-bottom: 16px;">receipt_long</span>
                    <p>暂无交易记录</p>
                    <p style="font-size: 14px; margin-top: 8px;">点击下方按钮开始记账</p>
                </div>
            `;
            return;
        }

        container.innerHTML = recentTransactions.map(transaction => {
            const iconMap = {
                food: 'restaurant',
                transport: 'directions_car',
                shopping: 'shopping_bag',
                entertainment: 'movie',
                healthcare: 'local_hospital',
                education: 'school',
                other: 'category'
            };

            const categoryNames = {
                food: '餐饮',
                transport: '交通',
                shopping: '购物',
                entertainment: '娱乐',
                healthcare: '医疗',
                education: '教育',
                other: '其他'
            };

            return `
                <div class="transaction-item">
                    <div class="transaction-icon ${transaction.category}">
                        <span class="material-icons">${iconMap[transaction.category] || 'category'}</span>
                    </div>
                    <div class="transaction-details">
                        <div class="transaction-title">${categoryNames[transaction.category] || '其他'}</div>
                        <div class="transaction-subtitle">${transaction.description} • ${this.formatDate(transaction.date)}</div>
                    </div>
                    <div class="transaction-amount ${transaction.type}">
                        ${transaction.type === 'expense' ? '-' : '+'}¥${transaction.amount.toFixed(2)}
                    </div>
                </div>
            `;
        }).join('');
    }

    // 更新余额显示
    updateBalance() {
        const balance = this.calculateBalance();
        const monthlyIncome = this.calculateMonthlyIncome();
        const monthlyExpense = this.calculateMonthlyExpense();
        
        document.getElementById('balanceAmount').textContent = `¥${balance.toFixed(2)}`;
        document.querySelector('.balance-item .amount.income').textContent = `+¥${monthlyIncome.toFixed(2)}`;
        document.querySelector('.balance-item .amount.expense').textContent = `-¥${monthlyExpense.toFixed(2)}`;
    }

    // 计算总余额
    calculateBalance() {
        return this.transactions.reduce((total, transaction) => {
            return transaction.type === 'income' 
                ? total + transaction.amount 
                : total - transaction.amount;
        }, 0);
    }

    // 计算本月收入
    calculateMonthlyIncome() {
        const currentMonth = new Date().getMonth();
        const currentYear = new Date().getFullYear();
        
        return this.transactions
            .filter(t => {
                const transactionDate = new Date(t.date);
                return t.type === 'income' && 
                       transactionDate.getMonth() === currentMonth &&
                       transactionDate.getFullYear() === currentYear;
            })
            .reduce((total, t) => total + t.amount, 0);
    }

    // 计算本月支出
    calculateMonthlyExpense() {
        const currentMonth = new Date().getMonth();
        const currentYear = new Date().getFullYear();
        
        return this.transactions
            .filter(t => {
                const transactionDate = new Date(t.date);
                return t.type === 'expense' && 
                       transactionDate.getMonth() === currentMonth &&
                       transactionDate.getFullYear() === currentYear;
            })
            .reduce((total, t) => total + t.amount, 0);
    }

    // 切换余额可见性
    toggleBalanceVisibility() {
        const balanceAmount = document.getElementById('balanceAmount');
        const toggleBtn = document.getElementById('balanceToggle');
        const icon = toggleBtn.querySelector('.material-icons');
        
        if (balanceAmount.style.filter === 'blur(8px)') {
            balanceAmount.style.filter = 'none';
            icon.textContent = 'visibility';
        } else {
            balanceAmount.style.filter = 'blur(8px)';
            icon.textContent = 'visibility_off';
        }
    }

    // 格式化日期
    formatDate(dateString) {
        const date = new Date(dateString);
        const today = new Date();
        const yesterday = new Date(today);
        yesterday.setDate(yesterday.getDate() - 1);
        
        if (date.toDateString() === today.toDateString()) {
            return '今天';
        } else if (date.toDateString() === yesterday.toDateString()) {
            return '昨天';
        } else {
            return `${date.getMonth() + 1}月${date.getDate()}日`;
        }
    }

    // 显示提示消息
    showToast(message) {
        // 创建提示元素
        const toast = document.createElement('div');
        toast.style.cssText = `
            position: fixed;
            top: 20px;
            left: 50%;
            transform: translateX(-50%);
            background: #4ade80;
            color: white;
            padding: 12px 24px;
            border-radius: 8px;
            font-size: 14px;
            font-weight: 500;
            z-index: 10000;
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
        `;
        toast.textContent = message;
        
        document.body.appendChild(toast);
        
        // 3秒后自动移除
        setTimeout(() => {
            if (toast.parentNode) {
                toast.parentNode.removeChild(toast);
            }
        }, 3000);
    }

    // 本地存储管理
    saveTransactions() {
        localStorage.setItem('expense_tracker_transactions', JSON.stringify(this.transactions));
    }

    loadTransactions() {
        const saved = localStorage.getItem('expense_tracker_transactions');
        if (saved) {
            return JSON.parse(saved);
        }
        
        // 返回空数组，用户从零开始记账
        return [];
    }
}

// 初始化应用
document.addEventListener('DOMContentLoaded', () => {
    new ExpenseTracker();
});

// PWA支持
if ('serviceWorker' in navigator) {
    window.addEventListener('load', () => {
        navigator.serviceWorker.register('/sw.js')
            .then(registration => {
                console.log('SW registered: ', registration);
            })
            .catch(registrationError => {
                console.log('SW registration failed: ', registrationError);
            });
    });
}
