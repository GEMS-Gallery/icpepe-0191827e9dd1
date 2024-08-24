import React, { useState, useEffect } from 'react';
import { backend } from 'declarations/backend';
import { Principal } from '@dfinity/principal';
import { Container, Typography, TextField, Button, Box, CircularProgress } from '@mui/material';
import { useForm, Controller } from 'react-hook-form';

function App() {
  const [balance, setBalance] = useState<bigint | null>(null);
  const [loading, setLoading] = useState(false);
  const { control, handleSubmit, reset } = useForm();

  useEffect(() => {
    fetchBalance();
  }, []);

  const fetchBalance = async () => {
    try {
      const result = await backend.icrc1_balance_of(Principal.fromText('2vxsx-fae'));
      setBalance(result);
    } catch (error) {
      console.error('Error fetching balance:', error);
    }
  };

  const onSubmit = async (data: { recipient: string; amount: string }) => {
    setLoading(true);
    try {
      const recipient = Principal.fromText(data.recipient);
      const amount = BigInt(data.amount);
      const result = await backend.icrc1_transfer(recipient, amount);
      if ('ok' in result) {
        console.log('Transfer successful');
        fetchBalance();
        reset();
      } else {
        console.error('Transfer failed:', result.err);
      }
    } catch (error) {
      console.error('Error during transfer:', error);
    }
    setLoading(false);
  };

  return (
    <Container maxWidth="sm">
      <Box sx={{ my: 4 }}>
        <Typography variant="h4" component="h1" gutterBottom>
          ICPepe Token
        </Typography>
        <Typography variant="h6" gutterBottom>
          Balance: {balance !== null ? balance.toString() : 'Loading...'}
        </Typography>
        <form onSubmit={handleSubmit(onSubmit)}>
          <Controller
            name="recipient"
            control={control}
            defaultValue=""
            rules={{ required: 'Recipient is required' }}
            render={({ field, fieldState: { error } }) => (
              <TextField
                {...field}
                label="Recipient"
                fullWidth
                margin="normal"
                error={!!error}
                helperText={error?.message}
              />
            )}
          />
          <Controller
            name="amount"
            control={control}
            defaultValue=""
            rules={{ required: 'Amount is required', pattern: { value: /^\d+$/, message: 'Must be a number' } }}
            render={({ field, fieldState: { error } }) => (
              <TextField
                {...field}
                label="Amount"
                fullWidth
                margin="normal"
                error={!!error}
                helperText={error?.message}
              />
            )}
          />
          <Button
            type="submit"
            variant="contained"
            color="primary"
            fullWidth
            disabled={loading}
            sx={{ mt: 2 }}
          >
            {loading ? <CircularProgress size={24} /> : 'Transfer'}
          </Button>
        </form>
      </Box>
    </Container>
  );
}

export default App;
