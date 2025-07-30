# PowerShell脚本：批量修复Flutter代码问题

Write-Host "开始修复Flutter代码问题..." -ForegroundColor Green

# 获取所有Dart文件
$dartFiles = Get-ChildItem -Path "lib" -Filter "*.dart" -Recurse

foreach ($file in $dartFiles) {
    Write-Host "处理文件: $($file.FullName)" -ForegroundColor Yellow
    
    $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
    $originalContent = $content
    
    # 修复withValues方法
    $content = $content -replace '\.withValues\(alpha:\s*([\d\.]+)\)', '.withOpacity($1)'
    
    # 修复FluentSystemIcons图标问题
    $iconMappings = @{
        'ic_fluent_mic_regular' = 'ic_fluent_mic_20_regular'
        'ic_fluent_calendar_ltr_20_regular' = 'ic_fluent_calendar_20_regular'
        'ic_fluent_eye_regular' = 'ic_fluent_eye_20_regular'
        'ic_fluent_brain_20_regular' = 'ic_fluent_person_20_regular'
        'ic_fluent_broom_20_regular' = 'ic_fluent_delete_20_regular'
        'ic_fluent_question_circle_20_regular' = 'ic_fluent_question_20_regular'
        'ic_fluent_document_arrow_up_20_regular' = 'ic_fluent_arrow_upload_20_regular'
        'ic_fluent_savings_20_regular' = 'ic_fluent_savings_20_regular'
        'ic_fluent_arrow_up_20_regular' = 'ic_fluent_arrow_up_20_regular'
    }
    
    foreach ($oldIcon in $iconMappings.Keys) {
        $newIcon = $iconMappings[$oldIcon]
        $content = $content -replace $oldIcon, $newIcon
    }
    
    # 如果内容有变化，保存文件
    if ($content -ne $originalContent) {
        Set-Content -Path $file.FullName -Value $content -Encoding UTF8
        Write-Host "已修复: $($file.Name)" -ForegroundColor Green
    }
}

Write-Host "修复完成！" -ForegroundColor Green