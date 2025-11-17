import type { FC } from 'react'
import { useState } from 'react'
import {
  Paper,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Chip,
  Box,
  Typography,
  CircularProgress,
  Alert,
  TablePagination,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
} from '@mui/material'
import {
  TrendingUp as TrendingUpIcon,
  TrendingDown as TrendingDownIcon,
} from '@mui/icons-material'
import { useQuery } from 'urql'
import { GET_POINT_TRANSACTION_HISTORY_QUERY } from '@api/queries'
import { formatPointsDiff } from '@lib/formatPoints'
import { format } from 'date-fns'
import { ru } from 'date-fns/locale'

type TransactionType = 'ALL' | 'EARNED' | 'SPENT' | 'RESERVED' | 'REFUNDED'

export interface TransactionHistoryTableProps {
  groupId?: string
}

export const TransactionHistoryTable: FC<TransactionHistoryTableProps> = ({ groupId }) => {
  const [page, setPage] = useState(0)
  const [rowsPerPage] = useState(20)
  const [typeFilter, setTypeFilter] = useState<TransactionType>('ALL')

  const [transactionsResult] = useQuery({
    query: GET_POINT_TRANSACTION_HISTORY_QUERY,
    variables: {
      groupId: groupId || null,
      limit: rowsPerPage,
      offset: page * rowsPerPage,
    },
  })

  const { data, fetching, error } = transactionsResult

  const getTransactionTypeLabel = (type: string): string => {
    switch (type) {
      case 'EARNED':
        return 'Заработано'
      case 'SPENT':
        return 'Потрачено'
      case 'RESERVED':
        return 'Зарезервировано'
      case 'REFUNDED':
        return 'Возвращено'
      default:
        return type
    }
  }

  const getTransactionTypeColor = (
    type: string
  ): 'default' | 'primary' | 'secondary' | 'error' | 'info' | 'success' | 'warning' => {
    switch (type) {
      case 'EARNED':
        return 'success'
      case 'SPENT':
        return 'error'
      case 'RESERVED':
        return 'warning'
      case 'REFUNDED':
        return 'info'
      default:
        return 'default'
    }
  }

  const getAmountDisplay = (amount: number, type: string) => {
    const isPositive = type === 'EARNED' || type === 'REFUNDED'
    return (
      <Box sx={{ display: 'flex', alignItems: 'center', gap: 0.5 }}>
        {isPositive ? (
          <TrendingUpIcon fontSize="small" color="success" />
        ) : (
          <TrendingDownIcon fontSize="small" color="error" />
        )}
        <Typography
          variant="body2"
          fontWeight={600}
          color={isPositive ? 'success.main' : 'error.main'}
        >
          {formatPointsDiff(amount)}
        </Typography>
      </Box>
    )
  }

  if (fetching) {
    return (
      <Box sx={{ display: 'flex', justifyContent: 'center', p: 4 }}>
        <CircularProgress />
      </Box>
    )
  }

  if (error) {
    return (
      <Alert severity="error">
        Ошибка загрузки истории транзакций: {error.message}
      </Alert>
    )
  }

  const transactions = data?.getPointTransactionHistory?.items || []
  const total = data?.getPointTransactionHistory?.total || 0

  // Filter transactions by type
  const filteredTransactions =
    typeFilter === 'ALL'
      ? transactions
      : transactions.filter((t: any) => t.type === typeFilter)

  if (transactions.length === 0) {
    return (
      <Paper sx={{ p: 4, textAlign: 'center' }}>
        <Typography variant="body1" color="text.secondary">
          Нет транзакций для отображения
        </Typography>
      </Paper>
    )
  }

  return (
    <Box>
      {/* Filter */}
      <Box sx={{ mb: 2 }}>
        <FormControl size="small" sx={{ minWidth: 200 }}>
          <InputLabel>Тип транзакции</InputLabel>
          <Select
            value={typeFilter}
            label="Тип транзакции"
            onChange={(e) => setTypeFilter(e.target.value as TransactionType)}
          >
            <MenuItem value="ALL">Все транзакции</MenuItem>
            <MenuItem value="EARNED">Заработано</MenuItem>
            <MenuItem value="SPENT">Потрачено</MenuItem>
            <MenuItem value="RESERVED">Зарезервировано</MenuItem>
            <MenuItem value="REFUNDED">Возвращено</MenuItem>
          </Select>
        </FormControl>
      </Box>

      <TableContainer component={Paper}>
        <Table>
          <TableHead>
            <TableRow>
              <TableCell>Дата</TableCell>
              <TableCell>Тип</TableCell>
              <TableCell>Описание</TableCell>
              <TableCell align="right">Сумма</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {filteredTransactions.map((transaction: any) => (
              <TableRow key={transaction.id} hover>
                <TableCell>
                  <Typography variant="body2">
                    {format(new Date(transaction.createdAt), 'dd MMM yyyy', { locale: ru })}
                  </Typography>
                  <Typography variant="caption" color="text.secondary">
                    {format(new Date(transaction.createdAt), 'HH:mm', { locale: ru })}
                  </Typography>
                </TableCell>
                <TableCell>
                  <Chip
                    label={getTransactionTypeLabel(transaction.type)}
                    color={getTransactionTypeColor(transaction.type)}
                    size="small"
                  />
                </TableCell>
                <TableCell>
                  <Typography variant="body2">{transaction.description}</Typography>
                  {transaction.relatedTaskTitle && (
                    <Typography variant="caption" color="text.secondary">
                      Задача: {transaction.relatedTaskTitle}
                    </Typography>
                  )}
                  {transaction.relatedRewardName && (
                    <Typography variant="caption" color="text.secondary">
                      Награда: {transaction.relatedRewardName}
                    </Typography>
                  )}
                </TableCell>
                <TableCell align="right">
                  {getAmountDisplay(transaction.amount, transaction.type)}
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>

        <TablePagination
          component="div"
          count={total}
          page={page}
          onPageChange={(_, newPage) => setPage(newPage)}
          rowsPerPage={rowsPerPage}
          rowsPerPageOptions={[rowsPerPage]}
          labelRowsPerPage="Строк на странице:"
          labelDisplayedRows={({ from, to, count }) => `${from}–${to} из ${count}`}
        />
      </TableContainer>
    </Box>
  )
}
