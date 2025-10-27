import { Box, Typography, Paper, Divider } from '@mui/material'
import { CalendarMonth as CalendarIcon, ChevronLeft as ChevronLeftIcon, ChevronRight as ChevronRightIcon } from '@mui/icons-material'
import { useState } from 'react'
import { useEffect } from 'react'

export function DashboardPage() {
  // Получить текущую неделю (понедельник-воскресенье)
  const today = new Date();
  const weekDays = ['вс', 'пн', 'вт', 'ср', 'чт', 'пт', 'сб'];
  const getWeekDay = (date: Date) => weekDays[date.getDay()];

  // Находим понедельник текущей недели
  const getMonday = (date: Date) => {
    const d = new Date(date);
    const day = d.getDay();
    // Если сегодня воскресенье (0), то понедельник — на 6 дней назад
    const diff = day === 0 ? -6 : 1 - day;
    d.setDate(d.getDate() + diff);
    d.setHours(0,0,0,0);
    return d;
  };

  // Состояние: смещение недели и выбранная дата
  const [weekOffset, setWeekOffset] = useState(0);
  const [selectedDate, setSelectedDate] = useState<Date | null>(null);

  // Генерация массива дат для текущей недели
  const getWeekDates = () => {
    const monday = getMonday(today);
    const dates = [];
    for (let i = 0; i < 7; i++) {
      const d = new Date(monday);
      d.setDate(monday.getDate() + weekOffset * 7 + i);
      dates.push(d);
    }
    return dates;
  };
  const datesList = getWeekDates();

  // Переключение недели
  const handlePrevPeriod = () => setWeekOffset(weekOffset - 1);
  const handleNextPeriod = () => setWeekOffset(weekOffset + 1);

  // После рендера автоматически выбрать текущую дату, если она в текущей неделе
  useEffect(() => {
    const found = datesList.find(d => d.toDateString() === today.toDateString());
    if (found) setSelectedDate(found);
    else setSelectedDate(datesList[0]);
  }, [weekOffset]);

  // Temporary mock data for upcoming tasks
  const upcomingTasks = [
    { id: '1', title: 'Убрать на кухне', date: '30 ВТ', time: '10:00' },
    { id: '2', title: 'Вынести мусор', date: '1 СР', time: '14:00' },
    { id: '3', title: 'Помыть пол', date: '2 ЧТ', time: '16:00' },
    { id: '4', title: 'Пропылесосить', date: '3 ПТ', time: '11:00' },
    { id: '5', title: 'Полить цветы', date: '5 ВС', time: '09:00' },
    { id: '6', title: 'Постирать', date: '6 ПН', time: '15:00' },
  ]

  return (
    <Box sx={{ display: 'flex', gap: 3, height: 'calc(100vh - 120px)' }}>
      {/* Left Side - Vertical Date Selector */}
      <Paper sx={{ width: 220, p: 2, display: 'flex', flexDirection: 'column', alignItems: 'center', height: '100%' }}>
        {/* Period navigation */}
        <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, mb: 2 }}>
          <ChevronLeftIcon fontSize="medium" sx={{ cursor: 'pointer' }} onClick={handlePrevPeriod} />
          <CalendarIcon fontSize="small" color="action" />
          <ChevronRightIcon fontSize="medium" sx={{ cursor: 'pointer' }} onClick={handleNextPeriod} />
        </Box>
        <Divider sx={{ width: '100%', mb: 2 }} />
        {/* Vertical list of dates, evenly distributed */}
        <Box sx={{ display: 'flex', flexDirection: 'column', justifyContent: 'space-between', height: '100%', width: '100%' }}>
          {datesList.map((date) => {
            const isSelected = selectedDate && date.toDateString() === selectedDate.toDateString();
            return (
              <Box
                key={date.toISOString()}
                onClick={() => setSelectedDate(date)}
                sx={{
                  display: 'flex',
                  alignItems: 'center',
                  gap: 2,
                  py: 1,
                  px: 2,
                  cursor: 'pointer',
                  transition: 'background-color 0.2s',
                }}
              >
                <Box
                  sx={{
                    width: 44,
                    height: 44,
                    borderRadius: '50%',
                    bgcolor: isSelected ? 'primary.main' : 'transparent',
                    color: isSelected ? 'primary.contrastText' : 'text.primary',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    fontWeight: 600,
                    fontSize: '1.5rem',
                    boxShadow: isSelected ? 2 : 0,
                    transition: 'background-color 0.2s',
                  }}
                >
                  {date.getDate()}
                </Box>
                <Typography variant="body1" sx={{ textTransform: 'lowercase', color: 'text.secondary', fontWeight: 500 }}>
                  {getWeekDay(date)}
                </Typography>
              </Box>
            )
          })}
        </Box>
      </Paper>
      {/* Right Side - Task List */}
      <Paper 
        sx={{ 
          flex: 1,
          p: 3, 
          display: 'flex', 
          flexDirection: 'column'
        }}
      >
        <Typography variant="h5" fontWeight={600} sx={{ mb: 1 }}>
          Список ближайших задач
        </Typography>
        <Divider sx={{ my: 2 }} />
        <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2, flex: 1 }}>
          {upcomingTasks.length === 0 ? (
            <Box sx={{ 
              display: 'flex', 
              alignItems: 'center', 
              justifyContent: 'center',
              flex: 1,
              color: 'text.secondary'
            }}>
              <Typography variant="body1">
                Нет задач
              </Typography>
            </Box>
          ) : (
            upcomingTasks.map((task) => (
              <Box
                key={task.id}
                sx={{
                  p: 2,
                  borderRadius: 2,
                  border: '1px solid',
                  borderColor: 'divider',
                  cursor: 'pointer',
                  transition: 'all 0.2s',
                  '&:hover': {
                    borderColor: 'primary.main',
                    boxShadow: 1,
                  },
                }}
              >
                <Typography variant="body1" fontWeight={500} sx={{ mb: 0.5 }}>
                  {task.title}
                </Typography>
                <Typography variant="body2" color="text.secondary">
                  {task.date} • {task.time}
                </Typography>
              </Box>
            ))
          )}
        </Box>
      </Paper>
    </Box>
  )
}
