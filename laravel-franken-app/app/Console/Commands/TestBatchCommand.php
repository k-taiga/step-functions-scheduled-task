<?php
// app/Console/Commands/TestBatchCommand.php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\Log;

class TestBatchCommand extends Command
{
    protected $signature = 'batch:test';
    protected $description = 'ECS定期実行テスト用コマンド';

    /**
     * @return int
     */
    public function handle(): int
    {
        $now = now()->format('Y-m-d H:iE:s');

        $this->info("バッチ実行テスト: {$now}");
        Log::info("ECSバッチ実行成功", [
            'executed_at' => $now,
            'environment' => config('app.env'),
            'container' => gethostname()
        ]);

        // 処理時間を確認するため少し待機
        sleep(5);

        $this->info("バッチ完了");
        return 0;
    }
}
