import { Box, Typography, Paper, IconButton, Divider } from '@mui/material'
import { ChevronLeft as ChevronLeftIcon, ChevronRight as ChevronRightIcon } from '@mui/icons-material'
import { useState } from 'react'

export function DashboardPage() {
  const [currentDate, setCurrentDate] = useState(new Date(2025, 9, 1)) // October 2025

  // Temporary mock data for upcoming tasks
  const upcomingTasks = [
    { id: '1', title: 'Убрать на кухне', date: '30 ВТ', time: '10:00' },
    { id: '2', title: 'Вынести мусор', date: '1 СР', time: '14:00' },
    { id: '3', title: 'Помыть пол', date: '2 ЧТ', time: '16:00' },
    { id: '4', title: 'Пропылесосить', date: '3 ПТ', time: '11:00' },
    { id: '5', title: 'Полить цветы', date: '5 ВС', time: '09:00' },
    { id: '6', title: 'Постирать', date: '6 ПН', time: '15:00' },
  ]

  const monthNames = [
    'Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь',
    'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь'
  ]

  const weekDays = ['пн', 'вт', 'ср', 'чт', 'пт', 'сб', 'вс']

  const getDaysInMonth = (date: Date) => {
    const year = date.getFullYear()
    const month = date.getMonth()
    const firstDay = new Date(year, month, 1)
    const lastDay = new Date(year, month + 1, 0)
    const daysInMonth = lastDay.getDate()
    
    // Get day of week (0 = Sunday, 1 = Monday, etc.)
    // Adjust so Monday = 0
    let startDay = firstDay.getDay() - 1
    if (startDay < 0) startDay = 6
    
    const days: (number | null)[] = []
    
    // Add empty cells for days before month starts
    for (let i = 0; i < startDay; i++) {
      days.push(null)
    }
    
    // Add days of month
    for (let i = 1; i <= daysInMonth; i++) {
      days.push(i)
    }
    
    return days
  }

  const handlePrevMonth = () => {
    setCurrentDate(new Date(currentDate.getFullYear(), currentDate.getMonth() - 1, 1))
  }

  const handleNextMonth = () => {
    setCurrentDate(new Date(currentDate.getFullYear(), currentDate.getMonth() + 1, 1))
  }

  const days = getDaysInMonth(currentDate)
  const today = new Date()
  const isCurrentMonth = currentDate.getMonth() === today.getMonth() && 
                         currentDate.getFullYear() === today.getFullYear()

  return (
    <Box sx={{ display: 'flex', gap: 3, height: 'calc(100vh - 120px)' }}>
      {/* Left Sidebar - Upcoming Tasks */}
      <Paper 
        sx={{ 
          width: 280, 
          p: 2, 
          display: 'flex', 
          flexDirection: 'column',
          height: 'fit-content'
        }}
      >
        <Typography variant="h6" fontWeight={600} sx={{ mb: 2 }}>
          Ближайшие задачи
        </Typography>
        <Divider sx={{ mb: 2 }} />
        <Box sx={{ display: 'flex', flexDirection: 'column', gap: 1 }}>
          {upcomingTasks.map((task) => (
            <Box
              key={task.id}
              sx={{
                p: 1.5,
                borderRadius: 1,
                bgcolor: 'action.hover',
                cursor: 'pointer',
                transition: 'background-color 0.2s',
                '&:hover': {
                  bgcolor: 'action.selected',
                },
              }}
            >
              <Typography variant="body2" fontWeight={500}>
                {task.title}
              </Typography>
              <Typography variant="caption" color="text.secondary">
                {task.date} • {task.time}
              </Typography>
            </Box>
          ))}
        </Box>
      </Paper>

      {/* Right Side - Calendar */}
      <Paper sx={{ flex: 1, p: 3, display: 'flex', flexDirection: 'column' }}>
        {/* Calendar Header */}
        <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'center', mb: 3 }}>
          <IconButton onClick={handlePrevMonth} size="small">
            <ChevronLeftIcon />
          </IconButton>
          <Typography variant="h6" fontWeight={600} sx={{ mx: 3, minWidth: 150, textAlign: 'center' }}>
            {monthNames[currentDate.getMonth()]} {currentDate.getFullYear()}
          </Typography>
          <IconButton onClick={handleNextMonth} size="small">
            <ChevronRightIcon />
          </IconButton>
        </Box>

        {/* Calendar Grid */}
        <Box sx={{ flex: 1, display: 'flex', flexDirection: 'column' }}>
          {/* Week day headers */}
          <Box 
            sx={{ 
              display: 'grid', 
              gridTemplateColumns: 'repeat(7, 1fr)', 
              gap: 1,
              mb: 1
            }}
          >
            {weekDays.map((day) => (
              <Box 
                key={day} 
                sx={{ 
                  textAlign: 'center', 
                  py: 1,
                  color: 'text.secondary',
                  fontWeight: 500,
                  fontSize: '0.875rem'
                }}
              >
                {day}
              </Box>
            ))}
          </Box>

          {/* Calendar days */}
          <Box 
            sx={{ 
              display: 'grid', 
              gridTemplateColumns: 'repeat(7, 1fr)', 
              gap: 1,
              flex: 1
            }}
          >
            {days.map((day, index) => {
              const isToday = isCurrentMonth && day === today.getDate()
              return (
                <Box
                  key={index}
                  sx={{
                    border: '1px solid',
                    borderColor: 'divider',
                    borderRadius: 1,
                    p: 1,
                    minHeight: 80,
                    bgcolor: day ? 'background.paper' : 'action.disabledBackground',
                    position: 'relative',
                    cursor: day ? 'pointer' : 'default',
                    transition: 'background-color 0.2s',
                    '&:hover': day ? {
                      bgcolor: 'action.hover',
                    } : {},
                  }}
                >
                  {day && (
                    <Typography 
                      variant="body2" 
                      fontWeight={isToday ? 700 : 400}
                      sx={{ 
                        color: isToday ? 'primary.main' : 'text.primary',
                        mb: 0.5
                      }}
                    >
                      {day}
                    </Typography>
                  )}
                </Box>
              )
            })}
          </Box>
        </Box>

        {/* Bottom Text */}
        <Box sx={{ mt: 3, textAlign: 'center' }}>
          <Typography variant="body2" color="text.secondary">
            Список ближайших задач
          </Typography>
        </Box>
      </Paper>
    </Box>
  )
}


